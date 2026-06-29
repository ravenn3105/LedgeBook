import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ledgebook.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notebooks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        currency TEXT NOT NULL DEFAULT 'INR',
        budget REAL,
        icon TEXT,
        color INTEGER,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_methods (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER,
        icon TEXT,
        usage_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        notebook_id TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        payment_method_id TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (notebook_id) REFERENCES notebooks (id) ON DELETE CASCADE,
        FOREIGN KEY (payment_method_id) REFERENCES payment_methods (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_tags (
        transaction_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (transaction_id, tag_id),
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        reference_id TEXT,
        amount REAL NOT NULL,
        period TEXT NOT NULL DEFAULT 'monthly',
        created_at INTEGER NOT NULL
      )
    ''');

    await _insertDefaults(db);
  }

  Future<void> _insertDefaults(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final methods = ['UPI', 'Cash', 'Debit Card', 'Credit Card', 'Bank Transfer', 'Wallet'];
    for (int i = 0; i < methods.length; i++) {
      await db.insert('payment_methods', {
        'id': 'default_${methods[i].toLowerCase().replaceAll(' ', '_')}',
        'name': methods[i],
        'is_default': i == 0 ? 1 : 0,
        'created_at': now,
      });
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> saveSharedPreferencesToDatabase() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    await db.delete('preferences');

    for (final key in keys) {
      final value = prefs.get(key);
      if (value != null) {
        String type = '';
        if (value is bool) {
          type = 'bool';
        } else if (value is int) {
          type = 'int';
        } else if (value is double) {
          type = 'double';
        } else if (value is String) {
          type = 'string';
        } else if (value is List<String>) {
          type = 'string_list';
        }

        if (type.isNotEmpty) {
          final valJson = jsonEncode({
            'type': type,
            'data': value,
          });

          await db.insert('preferences', {
            'key': key,
            'value': valJson,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    }
  }

  Future<void> restoreSharedPreferencesFromDatabase() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> maps = await db.query('preferences');
    for (final map in maps) {
      final key = map['key'] as String;
      final valJsonStr = map['value'] as String;

      try {
        final valMap = jsonDecode(valJsonStr) as Map<String, dynamic>;
        final type = valMap['type'] as String;
        final data = valMap['data'];

        if (type == 'bool') {
          await prefs.setBool(key, data as bool);
        } else if (type == 'int') {
          await prefs.setInt(key, data as int);
        } else if (type == 'double') {
          await prefs.setDouble(key, (data as num).toDouble());
        } else if (type == 'string') {
          await prefs.setString(key, data as String);
        } else if (type == 'string_list') {
          await prefs.setStringList(key, List<String>.from(data as List));
        }
      } catch (e) {
        // Ignored or logged
      }
    }
  }
}