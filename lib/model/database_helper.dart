import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'history.dart';
import 'item.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'inventory.db');
    return await openDatabase(
      path,
      version: 2, // Changed database version to 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add onUpgrade callback
    );
  }

  // This is called if the database version is increased.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // In this example, we simply recreate the database.
    // In a real app, you would migrate the data instead.
    await db.execute('DROP TABLE IF EXISTS items');
    await db.execute('DROP TABLE IF EXISTS history');
    _onCreate(db, newVersion); // Call _onCreate to create the new tables
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photo TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER NOT NULL,
        itemName TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (itemId) REFERENCES items(id)
      )
    ''');
  }

  // Insert an item
  Future<int> insertItem(Item item) async {
    Database db = await instance.database;
    return await db.insert('items', item.toMap());
  }

  // Get all items
  Future<List<Item>> getItems() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Update an item
  Future<int> updateItem(Item item) async {
    Database db = await instance.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete an item
  Future<int> deleteItem(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a history record
  Future<int> insertHistory(History history) async {
    Database db = await instance.database;
    return await db.insert('history', history.toMap());
  }

  // Get history records for an item
  Future<List<History>> getHistoryForItem(int itemId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    return List.generate(maps.length, (i) {
      return History.fromMap(maps[i]);
    });
  }

  Future<History?> getHistoryById(int historyId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'history',
      where: 'id = ?',
      whereArgs: [historyId],
    );

    if (result.isNotEmpty) {
      return History.fromMap(result.first);
    } else {
      return null;
    }
  }
  Future<int> updateHistory(History updatedHistory) async {
    Database db = await instance.database;
    return await db.update(
      'history',
      updatedHistory.toMap(),
      where: 'id = ?',
      whereArgs: [updatedHistory.id],
    );
  }

  Future<int> deleteHistory(int historyId) async {
    Database db = await instance.database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }
}