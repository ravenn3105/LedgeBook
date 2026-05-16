class TransactionModel {
  final String id;
  final String notebookId;
  final double amount;
  final String type;
  final String? note;
  final String? paymentMethodId;
  final int date;
  final int createdAt;
  final int updatedAt;

  TransactionModel({
    required this.id, required this.notebookId,
    required this.amount, required this.type,
    this.note, this.paymentMethodId,
    required this.date, required this.createdAt, required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'notebook_id': notebookId, 'amount': amount,
    'type': type, 'note': note, 'payment_method_id': paymentMethodId,
    'date': date, 'created_at': createdAt, 'updated_at': updatedAt,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'], notebookId: m['notebook_id'], amount: m['amount'],
    type: m['type'], note: m['note'], paymentMethodId: m['payment_method_id'],
    date: m['date'], createdAt: m['created_at'], updatedAt: m['updated_at'],
  );
}