import 'dart:typed_data';

class Item {
  final int id;
  final String name;
  final double price;
  final Uint8List? image;

  Item({this.id = 0, required this.name, required this.price, this.image});

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        id: map['id'],
        name: map['name'],
        price: map['price'],
        image: map['image']);
  }

  Map<String, dynamic> toMap() {
    if (image != null) {
      return {'name': name, 'price': price, 'image': image};
    } else {
      return {'name': name, 'price': price};
    }
  }

  @override
  String toString() {
    return '$name - \$${price.toStringAsFixed(2)}';
  }
}
