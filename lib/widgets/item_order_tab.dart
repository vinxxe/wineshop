//import 'dart:io'; // Import the dart:io package for File class

import 'package:flutter/material.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/models/order.dart';
import 'package:wine_shop/models/order_item.dart';
import 'package:wine_shop/utils/utils.dart';
import 'package:wine_shop/models/global_info.dart';

import 'select_item_screen.dart';

class ItemOrderTab extends StatefulWidget {
  static final GlobalKey<ItemOrderTabState> scaffoldKey = GlobalKey();
  final DatabaseHelper dbHelper;
  final GlobalInfo globalInfo;

  ItemOrderTab({required this.dbHelper, required this.globalInfo})
      : super(key: scaffoldKey);

  @override
  ItemOrderTabState createState() => ItemOrderTabState();
}

class ItemOrderTabState extends State<ItemOrderTab> {
  bool shouldUpdateList = false; // State variable to track update
  String _filterKeyword = ''; // Initialize with an empty string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<Item>>(
          future: _getItems(_filterKeyword),
          builder: (context, snapshot) {
            if (shouldUpdateList) {
              shouldUpdateList = false;
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No items found.');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return InkWell(
                    onTap: () async {
                      if (widget.globalInfo.currOrder != null){
                      final shouldUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectItemScreen(item: item)),
                      );
                      if (shouldUpdate == true) {
                        setState(() {
                          shouldUpdateList = true;
                        });
                      }
                      } else {
                        Utils.usrMsg(context, "NO ORDER", "Please, create a new order!");
                      }
                    },
                    child: ListTile(
                      title: Text(item.toString()),
                      leading: item.image != null
                          ? Image.memory(item.image!)
                          : const Icon(
                              Icons.image), // Show placeholder if no image
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "ht10",
                onPressed: () async {
                  if (widget.globalInfo.currOrder == null) {
                    print("no order created");
                    Order newOrder = Order();
                    newOrder.orderId = await widget.dbHelper.insertOrder(newOrder);
                    widget.globalInfo.currOrder = newOrder;
                  } else {
                    print (widget.globalInfo.currOrder!.orderId);
                    print (widget.globalInfo.currOrder!.orderDate);
                    widget.globalInfo.currOrder = null;
                  }
                  setState(() {
                    _filterKeyword = ''; // Clear the filter keyword
                  });
                },
                tooltip: 'Create Order',
                child: const Icon(Icons.add_shopping_cart_rounded),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht11",
                onPressed: () async {
                  final filter = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final filterController = TextEditingController();
                      return AlertDialog(
                        title: const Text('Search Items'),
                        content: TextField(
                          controller: filterController,
                          decoration: const InputDecoration(
                              labelText: 'Search by Name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, filterController.text);
                            },
                            child: const Text('Search'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, '');
                            },
                            child: const Text('Clear'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );

                  setState(() {
                    _filterKeyword = filter ?? '';
                  });
                },
                tooltip: 'Search Items',
                child: const Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht12",
                onPressed: () {
                  setState(() {
                    _filterKeyword = ''; // Clear the filter keyword
                  });
                },
                tooltip: 'Clear Filter',
                child: const Icon(Icons.clear),
              ),
            ]));
  }

  Future<List<Item>> _getItems(String? filter) async {
    final allItems = await widget.dbHelper.getAllItemsOrderedByName();

    if (filter == null || filter.isEmpty) {
      return allItems;
    }

    final filteredItems = allItems.where((item) {
      final lowerCaseFilter = filter.toLowerCase();
      return item.name.toLowerCase().contains(lowerCaseFilter);
    }).toList();

    return filteredItems;
  }
}
