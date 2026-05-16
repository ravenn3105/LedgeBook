import '../database/database_helper.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(BudgetModel budget) async {
    final db = await _db.database;
    await db.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('budgets');
    return result.map(BudgetModel.fromMap).toList();
  }

  Future<BudgetModel?> getByReference(String type, String referenceId) async {
    final db = await _db.database;
    final result = await db.query('budgets',
        where: 'type = ? AND reference_id = ?', whereArgs: [type, referenceId]);
    if (result.isEmpty) return null;
    return BudgetModel.fromMap(result.first);
  }

  Future<void> update(BudgetModel budget) async {
    final db = await _db.database;
    await db.update('budgets', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}