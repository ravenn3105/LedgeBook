import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(
    TransactionModel tx,
    List<String> tagIds,
  ) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      await txn.insert(
        'transactions',
        tx.toMap(),
      );

      for (final tagId in tagIds) {
        await txn.insert(
          'transaction_tags',
          {
            'transaction_id': tx.id,
            'tag_id': tagId,
          },
        );

        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usage_count = usage_count + 1
          WHERE id = ?
          ''',
          [tagId],
        );
      }
    });
  }

  Future<List<TransactionModel>> getByNotebook(
    String notebookId,
  ) async {
    final db = await _db.database;

    final result = await db.query(
      'transactions',
      where: 'notebook_id = ?',
      whereArgs: [notebookId],
      orderBy: 'date DESC',
    );

    return result
        .map(TransactionModel.fromMap)
        .toList();
  }

  Future<List<TransactionModel>> getByDateRange(
    int from,
    int to,
  ) async {
    final db = await _db.database;

    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [from, to],
      orderBy: 'date DESC',
    );

    return result
        .map(TransactionModel.fromMap)
        .toList();
  }

  Future<List<TransactionModel>> getAll() async {
    final db = await _db.database;

    final result = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return result
        .map(TransactionModel.fromMap)
        .toList();
  }

  Future<void> update(
    TransactionModel tx,
    List<String> tagIds,
  ) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      await txn.update(
        'transactions',
        tx.toMap(),
        where: 'id = ?',
        whereArgs: [tx.id],
      );

      await txn.delete(
        'transaction_tags',
        where: 'transaction_id = ?',
        whereArgs: [tx.id],
      );

      for (final tagId in tagIds) {
        await txn.insert(
          'transaction_tags',
          {
            'transaction_id': tx.id,
            'tag_id': tagId,
          },
        );
      }
    });
  }

  Future<void> delete(String id) async {
    final db = await _db.database;

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> search({
    String? query,
    String? notebookId,
    String? type,
    String? paymentMethodId,
    double? minAmount,
    double? maxAmount,
    int? fromDate,
    int? toDate,
  }) async {
    final db = await _db.database;

    String sql = '''
      SELECT DISTINCT transactions.* FROM transactions
      LEFT JOIN notebooks ON transactions.notebook_id = notebooks.id
      LEFT JOIN transaction_tags ON transactions.id = transaction_tags.transaction_id
      LEFT JOIN tags ON transaction_tags.tag_id = tags.id
      WHERE 1=1
    ''';

    final args = <dynamic>[];

    if (query != null && query.isNotEmpty) {
      sql += ''' AND (
        transactions.note LIKE ? OR
        notebooks.title LIKE ? OR
        tags.name LIKE ?
      )''';
      args.addAll(['%$query%', '%$query%', '%$query%']);
    }
    if (notebookId != null) {
      sql += ' AND transactions.notebook_id = ?';
      args.add(notebookId);
    }
    if (type != null) {
      sql += ' AND transactions.type = ?';
      args.add(type);
    }
    if (paymentMethodId != null) {
      sql += ' AND transactions.payment_method_id = ?';
      args.add(paymentMethodId);
    }
    if (minAmount != null) {
      sql += ' AND transactions.amount >= ?';
      args.add(minAmount);
    }
    if (maxAmount != null) {
      sql += ' AND transactions.amount <= ?';
      args.add(maxAmount);
    }
    if (fromDate != null) {
      sql += ' AND transactions.date >= ?';
      args.add(fromDate);
    }
    if (toDate != null) {
      sql += ' AND transactions.date <= ?';
      args.add(toDate);
    }

    sql += ' ORDER BY transactions.date DESC';

    final result = await db.rawQuery(sql, args);
    return result.map(TransactionModel.fromMap).toList();
  }
}