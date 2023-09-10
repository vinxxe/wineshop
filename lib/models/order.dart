enum OrderStatus {
  pending, // This status is used when an order is initially created but has not yet been processed or confirmed.
  processing, // The order is being prepared and processed, but it hasn't been shipped or delivered yet.
  shipped, // The order has been shipped and is on its way to the customer.
  delivered, // The order has been successfully delivered to the customer.
  cancelled, // The customer or the business has cancelled the order before it was shipped or delivered.
  onHold, // The order is temporarily on hold, often due to issues like payment problems, product availability, or other reasons. It is not currently being processed.
  returned, // The customer has returned all or part of the order for a refund or replacement.
  completed, // The order has been processed, shipped, delivered, and is considered complete.
  failed, // The order processing or payment processing failed, and it was not successful.
  refunded, // The order has been refunded in full or in part.
  backordered, // Some items in the order are not currently in stock and are placed on backorder until they become available.
  onHoldPayment // The order is on hold because there is an issue with the payment.
}

extension OrderStatusExt on OrderStatus {
  int get id {
    switch (this) {
      case OrderStatus.pending:
        return 100;
      case OrderStatus.processing:
        return 101;
      case OrderStatus.shipped:
        return 102;
      case OrderStatus.delivered:
        return 103;
      case OrderStatus.cancelled:
        return 104;
      case OrderStatus.onHold:
        return 105;
      case OrderStatus.returned:
        return 106;
      case OrderStatus.completed:
        return 107;
      case OrderStatus.failed:
        return 108;
      case OrderStatus.refunded:
        return 109;
      case OrderStatus.backordered:
        return 110;
      case OrderStatus.onHoldPayment:
        return 111;
    }
  }

  static OrderStatus getOrderStatus(int id) {
    for (OrderStatus status in OrderStatus.values) {
      if (status.id == id) {
        return status;
      }
    }
    return OrderStatus.pending; // Default status if not found.
  }
}

class Order {
  int orderId;
  int userId;
  DateTime orderDate;
  double totalAmount;
  OrderStatus status;

  Order({
    this.orderId = 0,
    this.userId = 0,
    required this.orderDate,
    required this.totalAmount,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'status': status.id,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'],
      userId: map['user_id'],
      orderDate: DateTime.parse(map['order_date']),
      totalAmount: map['total_amount'],
      status: OrderStatusExt.getOrderStatus(map['status']),
    );
  }
}
