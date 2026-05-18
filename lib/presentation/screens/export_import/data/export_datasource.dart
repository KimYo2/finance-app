import '../../../../data/datasources/smart_db_helper.dart';
import '../../../../data/datasources/pb_helper.dart';
import '../../../../data/datasources/local/sqlite_helper.dart';
import '../../../../data/models/transaction_model.dart';

class ExportDatasource {
  final SmartDbHelper _dbHelper;

  ExportDatasource({SmartDbHelper? dbHelper})
      : _dbHelper = dbHelper ?? SmartDbHelper(remote: PbHelper(), local: SqliteHelper());

  Future<List<TransactionModel>> fetchAll() => _dbHelper.fetchAllTransactions();

  Future<List<TransactionModel>> fetchByMonth(int month, int year) =>
      _dbHelper.fetchTransactionsByMonth(month, year);
}
