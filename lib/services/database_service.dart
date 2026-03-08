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
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE items ADD COLUMN quantity INTEGER NOT NULL DEFAULT 1');
    }

    // Some v2 installs were created without `quantity` due to an incomplete onCreate schema.
    if (oldVersion < 3) {
      final columns = await db.rawQuery('PRAGMA table_info(items)');
      final hasQuantity = columns.any((column) => column['name'] == 'quantity');
      if (!hasQuantity) {
        await db.execute('ALTER TABLE items ADD COLUMN quantity INTEGER NOT NULL DEFAULT 1');
      }
    }

    if (oldVersion < 4) {
      final columns = await db.rawQuery('PRAGMA table_info(items)');
      final hasLocationId = columns.any((column) => column['name'] == 'storageLocationId');
      if (!hasLocationId) {
        await db.execute('ALTER TABLE items ADD COLUMN storageLocationId TEXT');
      }

      await _ensureUncategorizedLocation(db);
      await _migrateItemLocationIds(db);
    }

    if (oldVersion < 5) {
      await _ensureUncategorizedLocation(db);
      await _migrateRemovedPresetLocationsToUncategorized(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        storageLocationId TEXT NOT NULL,
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

  Future<void> _ensureUncategorizedLocation(Database db) async {
    final existing = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [StorageLocation.uncategorizedId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final uncategorized = StorageLocation(
      id: StorageLocation.uncategorizedId,
      name: '未分类',
      icon: 'help_outline',
      isPreset: true,
    );
    await db.insert('locations', uncategorized.toMap());
  }

  Future<void> _migrateItemLocationIds(Database db) async {
    final locations = await db.query('locations', columns: ['id', 'name']);
    for (final location in locations) {
      await db.update(
        'items',
        {'storageLocationId': location['id']},
        where: "(storageLocationId IS NULL OR storageLocationId = '') AND storageLocation = ?",
        whereArgs: [location['name']],
      );
    }

    await db.update(
      'items',
      {'storageLocationId': StorageLocation.uncategorizedId},
      where: "storageLocationId IS NULL OR storageLocationId = ''",
    );
  }

  Future<void> _migrateRemovedPresetLocationsToUncategorized(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawUpdate(
      '''
      UPDATE items
      SET storageLocationId = ?, storageLocation = ?, updatedAt = ?
      WHERE storageLocationId IN ('preset_3', 'preset_4')
         OR storageLocation IN ('抽屉', '柜子')
      ''',
      [StorageLocation.uncategorizedId, '未分类', now],
    );

    await db.delete(
      'locations',
      where: 'id IN (?, ?)',
      whereArgs: ['preset_3', 'preset_4'],
    );
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

  Future<int> transferItemsByIds({
    required List<String> itemIds,
    required String toLocationId,
    required String toLocationName,
  }) async {
    if (itemIds.isEmpty) return 0;
    final db = await database;
    int totalUpdated = 0;

    await db.transaction((txn) async {
      const maxChunkSize = 500;
      for (int i = 0; i < itemIds.length; i += maxChunkSize) {
        final chunk = itemIds.skip(i).take(maxChunkSize).toList();
        final placeholders = List.filled(chunk.length, '?').join(',');
        final updated = await txn.rawUpdate(
          '''
          UPDATE items
          SET storageLocationId = ?, storageLocation = ?, updatedAt = ?
          WHERE id IN ($placeholders)
          ''',
          [
            toLocationId,
            toLocationName,
            DateTime.now().millisecondsSinceEpoch,
            ...chunk,
          ],
        );
        totalUpdated += updated;
      }
    });

    return totalUpdated;
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
