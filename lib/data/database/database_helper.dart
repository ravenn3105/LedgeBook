import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
}