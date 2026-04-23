class DebtModel {
  final String? id;
  final String title;
  final String type;
  final double amount;
  final double? remainingAmount;
  final String personName;
  final DateTime? dueDate;
  final DateTime? startDate;
  final bool isPaid;
  final String note;

  DebtModel({
    this.id,
    required this.title,
    required this.type,
    required this.amount,
    this.remainingAmount,
    this.personName = '',
    this.dueDate,
    this.startDate,
    this.isPaid = false,
    this.note = '',
  });

  String get safeId => id ?? '';

  double get remaining => remainingAmount ?? amount;

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as String?,
      title: map['title'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      remainingAmount: map['remaining_amount'] != null
          ? (map['remaining_amount'] as num).toDouble()
          : null,
      personName: (map['person_name'] as String?) ?? '',
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'] as String)
          : null,
      isPaid: (map['is_paid'] as bool?) ?? false,
      note: (map['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'amount': amount,
      'remaining_amount': remainingAmount ?? amount,
      'person_name': personName,
      'due_date': dueDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'is_paid': isPaid,
      'note': note,
    };
  }

  DebtModel copyWith({
    String? id,
    String? title,
    String? type,
    double? amount,
    double? remainingAmount,
    String? personName,
    DateTime? dueDate,
    DateTime? startDate,
    bool? isPaid,
    String? note,
  }) {
    return DebtModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      personName: personName ?? this.personName,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
    );
  }

  static const List<String> debtTypes = ['hutang', 'piutang'];

  static const Map<String, String> debtTypeLabels = {
    'hutang': 'Hutang',
    'piutang': 'Piutang',
  };
}