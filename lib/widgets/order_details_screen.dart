import 'package:flutter/material.dart';
import 'package:wine_shop/models/order.dart';
import 'package:wine_shop/models/order_item.dart';
import 'package:wine_shop/database/db_helper.dart';

class OrderDetailsScreen extends StatefulWidget {
  static final GlobalKey<OrderDetailsScreenState> scaffoldKey = GlobalKey();
  final Order order;
  final dbHelper = DatabaseHelper.instance;

  OrderDetailsScreen({required this.order}) : super(key: scaffoldKey);

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Total: \u20AC${widget.order.totalAmount}'),
      ),
      body: ListView.builder(
        itemCount: widget.order.items.length,
        itemBuilder: (context, index) {
          OrderItem orderItem = widget.order.items[index];
          return ListTile(
            title: Text('${orderItem.itemName}: '
                '(${orderItem.quantity} X \u20AC${(orderItem.price * 100).toInt()}) = '
                '\u20AC${orderItem.subtotal}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.order.totalAmount += orderItem.price;
                      orderItem.quantity++;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (orderItem.quantity > 0) {
                        widget.order.totalAmount -= orderItem.price;
                        orderItem.quantity--;
                      }
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ht30",
            onPressed: () async {
              widget.order.status = OrderStatus.completed;
              await widget.dbHelper.updateOrder(widget.order);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.check),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "ht31",
            onPressed: () async {
              widget.order.status = OrderStatus.cancelled;
              await widget.dbHelper.updateOrder(widget.order);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.clear),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "ht32",
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
