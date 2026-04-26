enum TransactionType {
  income,
  expense;

  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.expense,
    );
  }
}