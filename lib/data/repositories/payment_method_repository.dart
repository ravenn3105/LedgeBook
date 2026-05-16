import '../database/database_helper.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(PaymentMethodModel method) async {
    final db = await _db.database;
    await db.insert('payment_methods', method.toMap());
  }

  Future<List<PaymentMethodModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('payment_methods',
        orderBy: 'is_default DESC, created_at ASC');
    return result.map(PaymentMethodModel.fromMap).toList();
  }

  Future<void> update(PaymentMethodModel method) async {
    final db = await _db.database;
    await db.update('payment_methods', method.toMap(),
        where: 'id = ?', whereArgs: [method.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }
}