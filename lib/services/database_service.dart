import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import '../models/storage_location.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'storage.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 保持向后兼容：确保 items 表包含 quantity 列。
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE items ADD COLUMN quantity INTEGER DEFAULT 1');
    }

    if (oldVersion < 3) {
      // 有些旧数据库可能已经被标记为 version 2 但未包含该列，先检查再添加
      final List<Map<String, dynamic>> cols = await db.rawQuery("PRAGMA table_info('items')");
      final hasQuantity = cols.any((col) => col['name'] == 'quantity');
      if (!hasQuantity) {
        await db.execute('ALTER TABLE items ADD COLUMN quantity INTEGER DEFAULT 1');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        storageLocation TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        productionDate INTEGER,
        expirationDays INTEGER,
        expirationDate INTEGER,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE locations(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT NOT NULL,
        isPreset INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert preset locations
    for (final location in StorageLocation.presetLocations) {
      await db.insert('locations', location.toMap());
    }
  }

  // Item CRUD
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', item.toMap());
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(Item item) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [item.id]);
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      orderBy: 'expirationDate ASC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> searchItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'expirationDate ASC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  // Location CRUD
  Future<void> insertLocation(StorageLocation location) async {
    final db = await database;
    await db.insert('locations', location.toMap());
  }

  Future<void> deleteLocation(StorageLocation location) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [location.id]);
  }

  Future<List<StorageLocation>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return maps.map((map) => StorageLocation.fromMap(map)).toList();
  }
}
