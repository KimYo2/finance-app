import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uwangku/providers/transaction_provider.dart';
import '../mocks/mock_db_helper.dart';
import '../mocks/mock_connectivity.dart';
import '../helpers/transaction_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerAllMocks();
  
  late TransactionProvider provider;
  late MockDbHelper mockDb;

  setUp(() async {
    mockDb = MockDbHelper();
    provider = TransactionProvider();
    provider.switchStorage(mockDb);
    await provider.initialize();
    await provider.loadTransactions();
  });

  group('totalBalance', () {
    test('returns 0.0 with no transactions', () {
      expect(provider.totalBalance, 0.0);
    });

    test('returns income - expense', () async {
      await provider.addTransaction(makeIncome(500000));
      await provider.addTransaction(makeExpense(200000));
      await provider.loadTransactions();
      expect(provider.totalBalance, 300000.0);
    });

    test('returns negative when expense > income', () async {
      await provider.addTransaction(makeIncome(100000));
      await provider.addTransaction(makeExpense(300000));
      await provider.loadTransactions();
      expect(provider.totalBalance, -200000.0);
    });
  });

  group('monthlyIncome', () {
    test('only counts current month income', () async {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      await provider.addTransaction(makeIncome(400000, date: now));
      await provider.addTransaction(makeIncome(200000, date: lastMonth));
      await provider.loadTransactions();

      expect(provider.monthlyIncome, 400000.0);
    });

    test('does not count expenses as income', () async {
      await provider.addTransaction(makeIncome(300000));
      await provider.addTransaction(makeExpense(100000));
      await provider.loadTransactions();

      expect(provider.monthlyIncome, 300000.0);
    });
  });

  group('monthlyExpense', () {
    test('only counts current month expense', () async {
      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      await provider.addTransaction(makeExpense(150000, date: now));
      await provider.addTransaction(makeExpense(50000, date: nextMonth));
      await provider.loadTransactions();

      expect(provider.monthlyExpense, 150000.0);
    });

    test('does not count income as expense', () async {
      await provider.addTransaction(makeIncome(300000));
      await provider.addTransaction(makeExpense(100000));
      await provider.loadTransactions();

      expect(provider.monthlyExpense, 100000.0);
    });
  });

  group('getCategoryTotals', () {
    test('groups expenses by category correctly', () async {
      final now = DateTime.now();
      await provider.addTransaction(makeExpense(80000, category: 'Makanan', date: now));
      await provider.addTransaction(makeExpense(30000, category: 'Makanan', date: now));
      await provider.addTransaction(makeExpense(50000, category: 'Transport', date: now));
      await provider.loadTransactions();

      final totals = provider.getCategoryTotals(now.month, now.year);
      expect(totals['Makanan'], 110000.0);
      expect(totals['Transport'], 50000.0);
    });

    test('does NOT include income in category totals', () async {
      final now = DateTime.now();
      await provider.addTransaction(makeIncome(500000, category: 'Gaji', date: now));
      await provider.loadTransactions();

      final totals = provider.getCategoryTotals(now.month, now.year);
      expect(totals['Gaji'], isNull);
    });
  });

  group('addTransaction', () {
    test('increases transaction count', () async {
      expect(provider.allTransactions.length, 0);
      await provider.addTransaction(makeIncome(100000));
      expect(provider.allTransactions.length, 1);
    });

    test('adds income transaction correctly', () async {
      final income = makeIncome(250000, category: 'Gaji');
      await provider.addTransaction(income);
      expect(provider.totalBalance, 250000.0);
    });

    test('adds expense transaction correctly', () async {
      final expense = makeExpense(50000, category: 'Transport');
      await provider.addTransaction(expense);
      expect(provider.totalBalance, -50000.0);
    });
  });

  group('deleteTransaction', () {
    test('removes transaction by id', () async {
      await provider.addTransaction(makeIncome(100000));
      final id = provider.allTransactions.first.id!;
      await provider.deleteTransaction(id);
      expect(provider.allTransactions.isEmpty, true);
    });

    test('fails with nonexistent id', () async {
      String? capturedError;
      provider.onError = (msg) => capturedError = msg;

      await provider.deleteTransaction('nonexistent_id');
      expect(capturedError, isNotNull);
    });
  });

  group('getMonthlyIncomeByMonth', () {
    test('calculates income for specific month', () async {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      await provider.addTransaction(makeIncome(500000, date: now));
      await provider.addTransaction(makeIncome(300000, date: lastMonth));
      await provider.loadTransactions();

      expect(provider.getMonthlyIncomeByMonth(now.month, now.year), 500000.0);
    });
  });

  group('getMonthlyExpenseByMonth', () {
    test('calculates expense for specific month', () async {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      await provider.addTransaction(makeExpense(400000, date: now));
      await provider.addTransaction(makeExpense(100000, date: lastMonth));
      await provider.loadTransactions();

      expect(provider.getMonthlyExpenseByMonth(now.month, now.year), 400000.0);
    });
  });

  group('onError callback', () {
    test('fires when delete fails', () async {
      String? capturedError;
      provider.onError = (msg) => capturedError = msg;

      await provider.deleteTransaction('nonexistent_id');
      expect(capturedError, isNotNull);
    });
  });

  group('onSuccess callback', () {
    test('fires when transaction added successfully', () async {
      String? capturedSuccess;
      provider.onSuccess = (msg) => capturedSuccess = msg;

      await provider.addTransaction(makeIncome(100000));
      expect(capturedSuccess, isNotNull);
    });
  });
}