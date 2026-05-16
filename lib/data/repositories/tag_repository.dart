import '../database/database_helper.dart';
import '../models/tag_model.dart';

class TagRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(TagModel tag) async {
    final db = await _db.database;
    await db.insert('tags', tag.toMap());
  }

  Future<List<TagModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('tags', orderBy: 'usage_count DESC');
    return result.map(TagModel.fromMap).toList();
  }

  Future<List<TagModel>> getForTransaction(String transactionId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT tags.* FROM tags
      INNER JOIN transaction_tags ON tags.id = transaction_tags.tag_id
      WHERE transaction_tags.transaction_id = ?
    ''', [transactionId]);
    return result.map(TagModel.fromMap).toList();
  }

  Future<void> update(TagModel tag) async {
    final db = await _db.database;
    await db.update('tags', tag.toMap(), where: 'id = ?', whereArgs: [tag.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }
}