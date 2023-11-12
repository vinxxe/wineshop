import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import "order_item.dart";

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
  List<OrderItem> items = [];

  Order({
    this.orderId = 0,
    this.userId = 0,
    DateTime? orderDate,
    this.totalAmount = 0.0,
    this.status = OrderStatus.pending,
  }) : orderDate = orderDate ?? DateTime.now();

  @override
  String toString() {
    String res = '';
    res += '\nID    : $orderId';
    res += '\nUID   : $userId';
    res += '\nDate  : $orderDate';
    res += '\nTot   : $totalAmount';
    res += '\nStatus: $status';
    for (var item in items) {
      res += item.toString();
    }
    return res;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          orderId == other.orderId &&
          userId == other.userId &&
          totalAmount == other.totalAmount &&
          status == other.status &&
          (const DeepCollectionEquality()).equals(items, other.items);

  @override
  int get hashCode => orderId.hashCode;

  bool checkTotalAmount() {
    // Calculate the sum of subtotal from the Order_Items
    double totalSum = 0.0;
    for (final item in items) {
      totalSum += item.subtotal;
    }

    const mult = 1000.0;
    final sumA = (totalSum * mult).round() / mult;
    final sumB = (totalAmount * mult).round() / mult;
    return sumA == sumB;
  }

  bool addItem(OrderItem item) {
    bool res = false;
    if (checkTotalAmount()) {
      if (items.contains(item)) {
        int idx = items.indexWhere((litem) => litem == item);
        items[idx] = item;
        totalAmount = 0;
        for (final item in items) {
          totalAmount += item.subtotal;
        }
      } else {
        items.add(item);
        totalAmount += item.subtotal;
        res = true;
      }
    } else {
      print("ITEM ADD: WRONG ORDER TOTAL");
    }
    return res;
  }

  bool delItem(OrderItem item) {
    bool res = false;
    if (checkTotalAmount()) {
      if (items.contains(item)) {
        items.remove(item);
        totalAmount = 0;
        for (final item in items) {
          totalAmount += item.subtotal;
        }
        res = true;
      }
    } else {
      print("ITEM DEL: WRONG ORDER TOTAL");
    }
    return res;
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'order_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate),
      'total_amount': totalAmount,
      'status': status.id,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'],
      userId: map['user_id'],
      orderDate: DateTime.parse(map['order_date']),
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: OrderStatusExt.getOrderStatus(map['status']),
    );
  }
}
