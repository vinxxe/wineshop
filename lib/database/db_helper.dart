import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:wine_shop/models/item.dart';

class DatabaseHelper {
  static const String tableItemsName = "wineshop";
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$tableItemsName.db';

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableItemsName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        price REAL,
        image BLOB
      )
    ''');
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert(tableItemsName, item.toMap());
  }

  Future<double?> getPriceByName(String name) async {
    final db = await database;
    final result =
        await db.query(tableItemsName, where: 'name = ?', whereArgs: [name]);

    if (result.isEmpty) {
      return null;
    }

    return result.first['price'] as double?;
  }

  Future<List<Item>> getAllItemsOrderedByName() async {
    final db = await instance.database;

    final result = await db.query(
      tableItemsName,
      // Order by name in ascending order
      orderBy: 'name ASC',
    );

    return result.map((json) => Item.fromMap(json)).toList();
  }

  Future<void> updateItem(int id, Item updatedItem) async {
    final db = await instance.database;
    await db.update(
      tableItemsName,
      updatedItem.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(int id) async {
    final db = await instance.database;
    await db.delete(
      tableItemsName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Export database to a CSV file
  Future<void> exportDatabaseToCSV(String exportPath) async {
    final items = await getAllItemsOrderedByName(); // Query items from database

    final csvRows = items.map((item) => [item.name, item.price]).toList();
    final csvString = const ListToCsvConverter().convert(csvRows);

    final file = File(exportPath);
    await file.writeAsString(csvString);
  }
}
