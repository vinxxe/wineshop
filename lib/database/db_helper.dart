import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/models/order.dart';
import 'package:wine_shop/models/order_item.dart';
import 'package:wine_shop/models/user.dart';
import 'package:wine_shop/models/producer.dart';

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

  Future<Order?> getOrder(int orderId) async {
    Order? res;
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      "Orders",
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    if (result.isNotEmpty) {
      res = Order.fromMap(result[0]);
    }
    return res;
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

  // Update a User
  Future<void> updateUser(User updatedUser) async {
    final db = await instance.database;
    await db.update(
      'Users',
      updatedUser.toMap(),
      where: 'user_id = ?',
      whereArgs: [updatedUser.userId],
    );
  }

  // Retrieve all users
  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('Users');
    return result.map((json) => User.fromMap(json)).toList();
  }

  // Insert a user
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('Users', user.toMap());
  }

  // Delete a user by ID
  Future<void> deleteUser(int userId) async {
    final db = await instance.database;
    await db.delete('Users', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Retrieve all producers
  Future<List<Producer>> getAllProducers() async {
    final db = await instance.database;
    final result = await db.query('Producers');
    return result.map((json) => Producer.fromMap(json)).toList();
  }

  // Insert a producer
  Future<int> insertProducer(Producer producer) async {
    final db = await database;
    return await db.insert('Producers', producer.toMap());
  }

  // Delete a producer by ID
  Future<void> deleteProducer(int producerId) async {
    final db = await instance.database;
    await db
        .delete('Producers', where: 'producer_id = ?', whereArgs: [producerId]);
  }

  // Update a Producer
  Future<void> updateProducer(Producer updatedProducer) async {
    final db = await instance.database;
    await db.update(
      'Producers',
      updatedProducer.toMap(),
      where: 'producer_id = ?',
      whereArgs: [updatedProducer.producerId],
    );
  }

  // Retrieve all orders
  Future<List<Order>> getAllOrders() async {
    final db = await instance.database;
    final result = await db.query('Orders');
    return result.map((json) => Order.fromMap(json)).toList();
  }

  // Insert an order
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('Orders', order.toMap());
  }

  // Delete an order by ID
  Future<void> deleteOrder(int orderId) async {
    final db = await instance.database;
    await db.delete('Orders', where: 'order_id = ?', whereArgs: [orderId]);
  }

  // Retrieve all order items
  Future<List<OrderItem>> getAllOrderItems() async {
    final db = await instance.database;
    final result = await db.query('Order_Items');
    return result.map((json) => OrderItem.fromMap(json)).toList();
  }

  // Update an Order
  Future<void> updateOrder(Order updatedOrder) async {
    final db = await instance.database;
    await db.update(
      'Orders',
      updatedOrder.toMap(),
      where: 'order_id = ?',
      whereArgs: [updatedOrder.orderId],
    );
  }

  // Retrieve all Order_Items for a specific order, validate the total amount,
  // and update the order if necessary
  Future<List<OrderItem>> getOrderItemsForOrder(int orderId) async {
    final db = await instance.database;

    // Retrieve the order
    final order = await getOrder(orderId);

    // Retrieve all Order_Items for the given order_id
    final List<Map<String, dynamic>> result = await db.query(
      'Order_Items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    final orderItems = result.map((json) => OrderItem.fromMap(json)).toList();

    // Calculate the sum of subtotal from the Order_Items
    double totalSum = 0.0;
    for (final item in orderItems) {
      totalSum += item.subtotal;
    }

    // Check if the total amount matches the calculated sum
    if (order != null && order.totalAmount != totalSum) {
      // Total amount doesn't match, update the order and issue a message
      final double oldTotalAmount = order.totalAmount;
      order.totalAmount = totalSum;
      await updateOrder(order);

      final String message = 'Order total amount updated. '
          'Old total: $oldTotalAmount, New total: $totalSum';

      print(message); // You can print the message or handle it as needed.

      return orderItems;
    } else {
      // Total amount matches, no update needed
      return orderItems;
    }
  }

  // Insert an order item
  Future<int> insertOrderItem(OrderItem orderItem) async {
    final db = await database;
    return await db.insert('Order_Items', orderItem.toMap());
  }

  // Delete an order item by ID
  Future<void> deleteOrderItem(int orderItemId) async {
    final db = await instance.database;
    await db.delete('Order_Items',
        where: 'order_item_id = ?', whereArgs: [orderItemId]);
  }

  // Update an Order_Item
  Future<void> updateOrderItem(OrderItem updatedOrderItem) async {
    final db = await instance.database;
    await db.update(
      'Order_Items',
      updatedOrderItem.toMap(),
      where: 'order_item_id = ?',
      whereArgs: [updatedOrderItem.orderItemId],
    );
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

  Future<void> deleteItem(int id) async {
    final db = await instance.database;
    await db.delete(
      tableItemsName,
      where: 'item_id = ?',
      whereArgs: [id],
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
      INSERT OR IGNORE INTO Orders (order_id, user_id, order_date, total_amount, status) VALUES (100, 100, ${DateFormat('yyyy-mm-dd').format(DateTime.utc(1970, 1, 1))}, 0.0, ${OrderStatus.completed.id});
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
