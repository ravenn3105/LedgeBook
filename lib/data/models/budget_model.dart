class BudgetModel {
  final String id;
  final String type;
  final String? referenceId;
  final double amount;
  final String period;
  final int createdAt;

  BudgetModel({required this.id, required this.type,
    this.referenceId, required this.amount,
    this.period = 'monthly', required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'reference_id': referenceId,
    'amount': amount, 'period': period, 'created_at': createdAt,
  };

  factory BudgetModel.fromMap(Map<String, dynamic> m) => BudgetModel(
    id: m['id'], type: m['type'], referenceId: m['reference_id'],
    amount: m['amount'], period: m['period'] ?? 'monthly',
    createdAt: m['created_at'],
  );
}