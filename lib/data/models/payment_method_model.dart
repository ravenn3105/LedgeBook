class PaymentMethodModel {
  final String id;
  final String name;
  final bool isDefault;
  final int createdAt;

  PaymentMethodModel({required this.id, required this.name,
    this.isDefault = false, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name,
    'is_default': isDefault ? 1 : 0, 'created_at': createdAt,
  };

  factory PaymentMethodModel.fromMap(Map<String, dynamic> m) => PaymentMethodModel(
    id: m['id'], name: m['name'],
    isDefault: m['is_default'] == 1, createdAt: m['created_at'],
  );
}