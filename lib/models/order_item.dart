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

  void updateQuantity(int quantity, double subtotal) {
    this.quantity = quantity;
    this.subtotal = subtotal;
  }

  @override
  String toString() {
    return '$orderItemId, $orderId, $itemName - $quantity \u20AC $subtotal';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          orderId == other.orderId &&
          itemName == other.itemName;

  @override
  int get hashCode => orderItemId.hashCode;

  Map<String, dynamic> toMap() {
    return {
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
