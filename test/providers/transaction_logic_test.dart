import 'package:flutter_test/flutter_test.dart';
import 'package:uwangku/models/transaction_model.dart';
import 'package:uwangku/models/transaction_type.dart';

TransactionModel makeTransaction({
  String? id,
  String title = 'Test Transaction',
  double amount = 100000,
  TransactionType type = TransactionType.expense,
  String category = 'Makanan',
  DateTime? date,
  String note = '',
  bool isSynced = true,
}) {
  return TransactionModel(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category,
    date: date ?? DateTime.now(),
    note: note,
    isSynced: isSynced,
  );
}

TransactionModel makeIncome(double amount, {
  String title = 'Test Income',
  String category = 'Gaji',
  DateTime? date,
  String note = '',
}) {
  return makeTransaction(
    title: title,
    amount: amount,
    type: TransactionType.income,
    category: category,
    date: date,
    note: note,
  );
}

TransactionModel makeExpense(double amount, {
  String title = 'Test Expense',
  String category = 'Makanan',
  DateTime? date,
  String note = '',
}) {
  return makeTransaction(
    title: title,
    amount: amount,
    type: TransactionType.expense,
    category: category,
    date: date,
    note: note,
  );
}

void main() {
  group('TransactionModel', () {
    test('creates income transaction correctly', () {
      final income = makeIncome(500000, category: 'Gaji');
      expect(income.type, TransactionType.income);
      expect(income.amount, 500000);
      expect(income.category, 'Gaji');
    });

    test('creates expense transaction correctly', () {
      final expense = makeExpense(200000, category: 'Makanan');
      expect(expense.type, TransactionType.expense);
      expect(expense.amount, 200000);
      expect(expense.category, 'Makanan');
    });
  });

  group('Balance Calculation', () {
    double calculateTotalBalance(List<TransactionModel> transactions) {
      double income = 0;
      double expense = 0;
      for (final t in transactions) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
      return income - expense;
    }

    test('returns 0 with empty list', () {
      final balance = calculateTotalBalance(<TransactionModel>[]);
      expect(balance, 0.0);
    });

    test('calculates income - expense correctly', () {
      final transactions = <TransactionModel>[
        makeIncome(500000),
        makeExpense(200000),
      ];
      expect(calculateTotalBalance(transactions), 300000.0);
    });

    test('returns negative when expense > income', () {
      final transactions = <TransactionModel>[
        makeIncome(100000),
        makeExpense(300000),
      ];
      expect(calculateTotalBalance(transactions), -200000.0);
    });
  });

  group('Monthly Filter', () {
    List<TransactionModel> filterByMonth(List<TransactionModel> transactions, int month, int year) {
      return transactions.where((t) => t.date.month == month && t.date.year == year).toList();
    }

    test('filters transactions by month correctly', () {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final transactions = <TransactionModel>[
        makeIncome(400000, date: now),
        makeIncome(200000, date: lastMonth),
      ];

      final filtered = filterByMonth(transactions, now.month, now.year);
      expect(filtered.length, 1);
      expect(filtered.first.amount, 400000);
    });
  });

  group('Category Totals', () {
    Map<String, double> calculateCategoryTotals(List<TransactionModel> transactions, int month, int year) {
      final Map<String, double> categoryTotals = {};
      final filtered = transactions.where((t) =>
          t.type == TransactionType.expense &&
          t.date.month == month &&
          t.date.year == year);

      for (final t in filtered) {
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      }
      return categoryTotals;
    }

    test('groups expenses by category correctly', () {
      final now = DateTime.now();
      final transactions = <TransactionModel>[
        makeExpense(80000, category: 'Makanan', date: now),
        makeExpense(30000, category: 'Makanan', date: now),
        makeExpense(50000, category: 'Transport', date: now),
      ];

      final totals = calculateCategoryTotals(transactions, now.month, now.year);
      expect(totals['Makanan'], 110000.0);
      expect(totals['Transport'], 50000.0);
    });

    test('excludes income from category totals', () {
      final now = DateTime.now();
      final transactions = <TransactionModel>[
        makeIncome(500000, category: 'Gaji', date: now),
      ];

      final totals = calculateCategoryTotals(transactions, now.month, now.year);
      expect(totals['Gaji'], isNull);
    });
  });

  group('Monthly Income', () {
    double calculateMonthlyIncome(List<TransactionModel> transactions, int month, int year) {
      return transactions
          .where((t) =>
              t.type == TransactionType.income &&
              t.date.month == month &&
              t.date.year == year)
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    test('calculates income for specific month', () {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final transactions = <TransactionModel>[
        makeIncome(500000, date: now),
        makeIncome(300000, date: lastMonth),
      ];

      expect(calculateMonthlyIncome(transactions, now.month, now.year), 500000.0);
    });

    test('excludes expenses from income', () {
      final now = DateTime.now();
      final transactions = <TransactionModel>[
        makeIncome(300000, date: now),
        makeExpense(100000, date: now),
      ];

      expect(calculateMonthlyIncome(transactions, now.month, now.year), 300000.0);
    });
  });

  group('Monthly Expense', () {
    double calculateMonthlyExpense(List<TransactionModel> transactions, int month, int year) {
      return transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.month == month &&
              t.date.year == year)
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    test('calculates expense for specific month', () {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final transactions = <TransactionModel>[
        makeExpense(400000, date: now),
        makeExpense(100000, date: lastMonth),
      ];

      expect(calculateMonthlyExpense(transactions, now.month, now.year), 400000.0);
    });

    test('excludes income from expense', () {
      final now = DateTime.now();
      final transactions = <TransactionModel>[
        makeIncome(300000, date: now),
        makeExpense(100000, date: now),
      ];

      expect(calculateMonthlyExpense(transactions, now.month, now.year), 100000.0);
    });
  });
}