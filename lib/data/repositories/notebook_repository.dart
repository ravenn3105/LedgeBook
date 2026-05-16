import '../database/database_helper.dart';
import '../models/notebook_model.dart';

class NotebookRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(NotebookModel notebook) async {
    final db = await _db.database;
    await db.insert('notebooks', notebook.toMap());
  }

  Future<List<NotebookModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('notebooks',
        where: 'is_archived = ?', whereArgs: [0], orderBy: 'created_at DESC');
    return result.map(NotebookModel.fromMap).toList();
  }

  Future<NotebookModel?> getById(String id) async {
    final db = await _db.database;
    final result = await db.query('notebooks', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return NotebookModel.fromMap(result.first);
  }

  Future<void> update(NotebookModel notebook) async {
    final db = await _db.database;
    await db.update('notebooks', notebook.toMap(),
        where: 'id = ?', whereArgs: [notebook.id]);
  }

  Future<void> archive(String id) async {
    final db = await _db.database;
    await db.update('notebooks', {'is_archived': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('notebooks', where: 'id = ?', whereArgs: [id]);
  }
}