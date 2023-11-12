class OrderItem {
  int orderItemId;
  int orderId;
  String itemName;
  int quantity;
  double price;

  OrderItem(
      {this.orderItemId = 0,
      this.orderId = 0,
      required this.itemName,
      this.quantity = 0,
      required this.price});

  @override
  String toString() {
    return '\n$orderItemId, $orderId, $itemName - ($quantity * \u20AC$price) \u20AC$subtotal';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          orderId == other.orderId &&
          itemName == other.itemName;

  @override
  int get hashCode => orderItemId.hashCode;

  double get subtotal => (quantity * price);

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderItemId: map['order_item_id'],
      orderId: map['order_id'],
      itemName: map['item_name'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
    );
  }
}
