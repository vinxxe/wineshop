import 'package:flutter/material.dart';
import 'package:wine_shop/models/global_info.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/models/order_item.dart';
import 'package:wine_shop/models/order.dart';

class SelectItemScreen extends StatefulWidget {
  static final GlobalKey<SelectItemScreenState> scaffoldKey = GlobalKey();
  final Item item;
  final dbHelper = DatabaseHelper.instance;

  SelectItemScreen({required this.item}) : super(key: scaffoldKey);

  @override
  SelectItemScreenState createState() => SelectItemScreenState();
}

class SelectItemScreenState extends State<SelectItemScreen> {
  int itemCount = 1;
  final TextEditingController countController = TextEditingController();
  late Item _item;
  late OrderItem _orderItem;
  final Order _currOrder = GlobalInfo.instance.currOrder!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Select Item')),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_item.name} - \u20AC${_item.price}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  // Container to adjust the alignment of the displayed image
                  Container(
                    alignment:
                        Alignment.topCenter, // Adjust the alignment as needed
                    child: _item.image != null
                        ? Image.memory(_item.image!)
                        : const SizedBox(), // You can use any empty widget here
                  ),
                  Row(
                      // Align items horizontally in the center
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (itemCount > 0) {
                                itemCount--;
                                countController.text = '$itemCount';
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            textAlign: TextAlign.center, // Center the text
                            controller: countController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              itemCount++;
                              countController.text = '$itemCount';
                            });
                          },
                        ),
                      ]),
                  const SizedBox(height: 8),
                  Row(
                      // Align items horizontally in the center
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // insert item into database if itemCount > 0
                            if (itemCount > 0) {
                              _orderItem.quantity = itemCount;
                              _currOrder.addItem(_orderItem);
                            } else {
                              // either delete the order item or do nothing
                              if (_currOrder.delItem(_orderItem)) {
                                widget.dbHelper
                                    .deleteOrderItem(_orderItem.orderItemId);
                              }
                            }
                            await widget.dbHelper.updateOrder(_currOrder);
                            if (context.mounted) {
                              Navigator.pop(
                                  context, true); // Go back to previous screen
                            }
                          },
                          child: const Text('Ok'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (context.mounted) {
                              Navigator.pop(
                                  context, true); // Go back to previous screen
                            }
                          },
                          child: const Text('Cancel'),
                        )
                      ])
                ])));
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    super.initState();
    _item = widget.item;
    _orderItem = await widget.dbHelper
        .getOrderItem(_currOrder.orderId, _item.name, _item.price);
    itemCount = _orderItem.quantity;
    countController.text = '$itemCount';
  }
}
