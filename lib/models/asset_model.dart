class AssetModel {
  final String? id;
  final String name;
  final String type;
  final double amount;
  final String currency;
  final DateTime? purchaseDate;
  final String note;
  final bool isActive;

  AssetModel({
    this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.currency = 'IDR',
    this.purchaseDate,
    this.note = '',
    this.isActive = true,
  });

  String get safeId => id ?? '';

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: (map['currency'] as String?) ?? 'IDR',
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      note: (map['note'] as String?) ?? '',
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'amount': amount,
      'currency': currency,
      'purchase_date': purchaseDate?.toIso8601String(),
      'note': note,
      'is_active': isActive,
    };
  }

  AssetModel copyWith({
    String? id,
    String? name,
    String? type,
    double? amount,
    String? currency,
    DateTime? purchaseDate,
    String? note,
    bool? isActive,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }

  static const List<String> assetTypes = [
    'cash',
    'bank',
    'investment',
    'property',
    'vehicle',
    'electronics',
    'other',
  ];

  static const Map<String, String> assetTypeLabels = {
    'cash': 'Tunai',
    'bank': 'Bank',
    'investment': 'Investasi',
    'property': 'Properti',
    'vehicle': 'Kendaraan',
    'electronics': 'Elektronik',
    'other': 'Lainnya',
  };
}