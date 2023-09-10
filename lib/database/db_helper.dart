import 'package:sqflite/sqflite.dart';
import 'package:wine_shop/models/item.dart';

class DatabaseHelper {
  static const String dbName = "wineshop.4";
  static const String tableItemsName = "wineshop_items";
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

  Future<void> deleteItem(int id) async {
    final db = await instance.database;
    await db.delete(
      tableItemsName,
      where: 'item_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getProducerID(String prodName) async {
    int res = 0;
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      "Producers",
      where: 'producer_name = ?',
      whereArgs: [prodName],
    );
    if (result.isNotEmpty) {
      res = result[0]['producer_id'] as int;
    }
    return res;
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

  Future<double?> getPriceByName(String name) async {
    final db = await database;
    final result =
        await db.query(tableItemsName, where: 'name = ?', whereArgs: [name]);

    if (result.isEmpty) {
      return null;
    }

    return result.first['price'] as double?;
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert(tableItemsName, item.toMap());
  }

  Future<void> updateItem(Item updatedItem) async {
    final db = await instance.database;
    await db.update(
      tableItemsName,
      updatedItem.toMap(),
      where: 'item_id = ?',
      whereArgs: [updatedItem.id],
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT,
        password TEXT,
        first_name TEXT,
        last_name TEXT,
        address TEXT,
        phone_number TEXT
      )
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO Users (user_id, username, email, password) VALUES (100, 'NONE','NONE','NONE');
    ''');

    await db.execute('''
      CREATE TABLE Producers (
        producer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        producer_name TEXT NON NULL UNIQUE
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO Producers (producer_id, producer_name) VALUES (100, 'NONE');
    ''');

    await db.execute('''
      CREATE TABLE $tableItemsName (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        price REAL NOT NULL,
        image BLOB,
        type INTEGER NOT NULL,
        country INTEGER NOT NULL,
        region INTEGER NOT NULL,
        vintage INTEGER,
        stock INTEGER,
        sold INTEGER,
        producer INTEGER NOT NULL,
        description TEXT,
        FOREIGN KEY (producer) REFERENCES Producers (producer_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Orders (
        order_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        order_date DATE NOT NULL,
        total_amount REAL NOT NULL,
        status INTEGER,
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Order_Items (
        order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES Orders (order_id),
        FOREIGN KEY (item_name) REFERENCES $tableItemsName (name)
      )
    ''');
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$dbName.db';
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }
}
