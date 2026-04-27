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