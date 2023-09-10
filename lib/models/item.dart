import 'dart:typed_data';

enum ItemType { none, redWine, whiteWine, roseWine, sparklingWine }

extension ItemExt on ItemType {
  int get id {
    switch (this) {
      case ItemType.none:
        return 100;
      case ItemType.redWine:
        return 101;
      case ItemType.whiteWine:
        return 102;
      case ItemType.roseWine:
        return 103;
      case ItemType.sparklingWine:
        return 104;
    }
  }

  static ItemType getItemType(int id) {
    for (ItemType itemType in ItemType.values) {
      if (itemType.id == id) {
        return itemType;
      }
    }
    return ItemType.none;
  }
}

enum Country { none, italia, francia, slovenia, portogallo }

extension CountryExt on Country {
  int get id {
    switch (this) {
      case Country.none:
        return 100;
      case Country.italia:
        return 101;
      case Country.francia:
        return 102;
      case Country.slovenia:
        return 103;
      case Country.portogallo:
        return 104;
    }
  }

  static Country getCountry(int id) {
    for (Country country in Country.values) {
      if (country.id == id) {
        return country;
      }
    }
    return Country.none;
  }
}

enum Region {
  none,
  abruzzo,
  altoAdige,
  basilicata,
  calabria,
  campania,
  emiliaRomagna,
  friuli,
  lazio,
  liguria,
  lombardia,
  marche,
  molise,
  piemonte,
  puglia,
  toscana,
  trentino,
  sardegna,
  sicilia,
  umbria,
  valDaosta,
  veneto,
}

class RegionId {
  final int id;
  const RegionId(this.id);
}

extension RegionExt on Region {
  int get id {
    switch (this) {
      case Region.none:
        return 100;
      case Region.abruzzo:
        return 101;
      case Region.altoAdige:
        return 102;
      case Region.basilicata:
        return 103;
      case Region.calabria:
        return 104;
      case Region.campania:
        return 105;
      case Region.emiliaRomagna:
        return 106;
      case Region.friuli:
        return 107;
      case Region.lazio:
        return 108;
      case Region.liguria:
        return 109;
      case Region.lombardia:
        return 110;
      case Region.marche:
        return 111;
      case Region.molise:
        return 112;
      case Region.piemonte:
        return 113;
      case Region.puglia:
        return 114;
      case Region.toscana:
        return 115;
      case Region.trentino:
        return 116;
      case Region.sardegna:
        return 117;
      case Region.sicilia:
        return 118;
      case Region.umbria:
        return 119;
      case Region.valDaosta:
        return 120;
      case Region.veneto:
        return 121;
    }
  }

  static Region getRegion(int id) {
    for (Region region in Region.values) {
      if (region.id == id) {
        return region;
      }
    }
    return Region.none; // Return null if no matching identifier is found
  }
}

class Item {
  int id;
  String name;
  double price;
  Uint8List? image;
  ItemType type;
  Country country;
  Region region;
  int vintage;
  int stock;
  int sold;
  int producer;
  String description;

  Item(
      {this.id = 0,
      required this.name,
      required this.price,
      this.image,
      this.type = ItemType.none,
      this.country = Country.none,
      this.region = Region.none,
      this.vintage = 0,
      this.stock = 0,
      this.sold = 0,
      this.producer = 0,
      this.description = ""});

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        id: map['item_id'],
        name: map['name'],
        price: map['price'],
        image: map['image'],
        type: ItemExt.getItemType(map['type']),
        country: CountryExt.getCountry(map['country']),
        region: RegionExt.getRegion(map['region']),
        vintage: map['vintage'],
        stock: map['stock'],
        sold: map['sold'],
        producer: map['producer'],
        description: map['description']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'type': type.id,
      'country': country.id,
      'region': region.id,
      'vintage': vintage,
      'stock': stock,
      'sold': sold,
      'producer': producer,
      'description': description
    };
  }

  @override
  String toString() {
    return '$name - \$${price.toStringAsFixed(2)}';
  }
}

class OrderItem {
  int orderItemId;
  int orderId;
  String itemName;
  int quantity;
  double subtotal;

  OrderItem(
      {this.orderItemId = 0,
      this.orderId = 0,
      required this.itemName,
      this.quantity = 0,
      this.subtotal = 0.0});

  Map<String, dynamic> toMap() {
    return {
      'order_item_id': orderItemId,
      'order_id': orderId,
      'item_name': itemName,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderItemId: map['order_item_id'],
      orderId: map['order_id'],
      itemName: map['item_name'],
      quantity: map['quantity'],
      subtotal: map['subtotal'],
    );
  }
}

// User class
class User {
  int? userId;
  String username;
  String email;
  String password;
  String? firstName;
  String? lastName;
  String? address;
  String? phoneNumber;

  User({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.address,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      address: map['address'],
      phoneNumber: map['phone_number'],
    );
  }
}

// Producer class
class Producer {
  int? producerId;
  String producerName;

  Producer({
    this.producerId,
    required this.producerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'producer_id': producerId,
      'producer_name': producerName,
    };
  }

  factory Producer.fromMap(Map<String, dynamic> map) {
    return Producer(
      producerId: map['producer_id'],
      producerName: map['producer_name'],
    );
  }
}

// Order class
class Order {
  int? orderId;
  int? userId;
  DateTime orderDate;
  double totalAmount;
  int? status;

  Order({
    this.orderId,
    this.userId,
    required this.orderDate,
    required this.totalAmount,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'],
      userId: map['user_id'],
      orderDate: DateTime.parse(map['order_date']),
      totalAmount: map['total_amount'],
      status: map['status'],
    );
  }
}
