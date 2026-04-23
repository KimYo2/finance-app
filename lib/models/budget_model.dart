class BudgetModel {
  final String? id;
  final String name;
  final double amount;
  final double spent;
  final String category;
  final int month;
  final int year;
  final String note;
  final bool isActive;

  BudgetModel({
    this.id,
    required this.name,
    required this.amount,
    this.spent = 0,
    this.category = '',
    required this.month,
    required this.year,
    this.note = '',
    this.isActive = true,
  });

  String get safeId => id ?? '';

  double get remaining => amount - spent;

  double get percentage => amount > 0 ? (spent / amount) * 100 : 0;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num?)?.toDouble() ?? 0,
      category: (map['category'] as String?) ?? '',
      month: map['month'] as int,
      year: map['year'] as int,
      note: (map['note'] as String?) ?? '',
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'spent': spent,
      'category': category,
      'month': month,
      'year': year,
      'note': note,
      'is_active': isActive,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    String? category,
    int? month,
    int? year,
    String? note,
    bool? isActive,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      category: category ?? this.category,
      month: month ?? this.month,
      year: year ?? this.year,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }
}