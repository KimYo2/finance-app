import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../database/db_interface.dart';
import '../database/sqlite_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  DbInterface _dbHelper = SqliteHelper();
  final Connectivity _connectivity = Connectivity();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    await _dbHelper.initialize();
    await checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    notifyListeners();
  }

  void switchStorage(DbInterface newStorage) {
    _dbHelper = newStorage;
    initialize();
  }

  Future<void> loadTransactions() async {
    if (_dbHelper is! SqliteHelper) {
      await checkConnectivity();
      if (!_isOnline) {
        _errorMessage = 'Tidak ada koneksi internet';
        _isLoading = false;
        notifyListeners();
        return;
      }
    } else {
      _isOnline = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _dbHelper.fetchAllTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    if (_dbHelper is! SqliteHelper) {
      await checkConnectivity();
      if (!_isOnline) {
        _errorMessage = 'Tidak ada koneksi internet';
        notifyListeners();
        return false;
      }
    } else {
      _isOnline = true;
    }

    try {
      final newTransaction = await _dbHelper.createTransaction(transaction);
      _transactions.insert(0, newTransaction);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    if (_dbHelper is! SqliteHelper) {
      await checkConnectivity();
      if (!_isOnline) {
        _errorMessage = 'Tidak ada koneksi internet';
        notifyListeners();
        return false;
      }
    } else {
      _isOnline = true;
    }

    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    if (_dbHelper is! SqliteHelper) {
      await checkConnectivity();
      if (!_isOnline) {
        _errorMessage = 'Tidak ada koneksi internet';
        notifyListeners();
        return false;
      }
    } else {
      _isOnline = true;
    }

    try {
      final transactionId = transaction.safeId;
      if (transactionId.isEmpty) {
        _errorMessage = 'Transaction ID is required for update';
        return false;
      }
      final updatedTransaction = await _dbHelper.updateTransaction(transactionId, transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  double get totalBalance {
    double income = 0;
    double expense = 0;
    for (final t in _transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return income - expense;
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryTotals(int month, int year) {
    final Map<String, double> categoryTotals = {};
    final filteredTransactions = _transactions.where((t) =>
        t.type == 'expense' &&
        t.date.month == month &&
        t.date.year == year);

    for (final t in filteredTransactions) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    return categoryTotals;
  }

  List<TransactionModel> getRecentTransactions(int limit) {
    return _transactions.take(limit).toList();
  }

  double getMonthlyIncomeByMonth(int month, int year) {
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.month == month &&
            t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpenseByMonth(int month, int year) {
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == month &&
            t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}