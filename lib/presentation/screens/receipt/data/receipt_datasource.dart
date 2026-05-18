import '../../../../data/datasources/smart_db_helper.dart';
import '../../../../data/datasources/pb_helper.dart';
import '../../../../data/datasources/local/sqlite_helper.dart';
import '../../../../data/models/transaction_model.dart';

class ReceiptDatasource {
  final SmartDbHelper _dbHelper;

  ReceiptDatasource({SmartDbHelper? dbHelper})
      : _dbHelper = dbHelper ?? SmartDbHelper(remote: PbHelper(), local: SqliteHelper());

  Future<TransactionModel> createTransaction(TransactionModel t) =>
      _dbHelper.createTransaction(t);
}
