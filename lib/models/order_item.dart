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
