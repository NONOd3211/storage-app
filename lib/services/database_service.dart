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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        storageLocation TEXT NOT NULL,
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
