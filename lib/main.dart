import 'package:flutter/material.dart';

import 'widgets/insert_item_tab.dart';
import 'widgets/item_list_tab.dart';
import 'widgets/item_order_tab.dart';
import 'database/db_helper.dart';
import 'models/global_info.dart';

void main() {
  runApp(const WineShopApp());
}

class WineShopApp extends StatelessWidget {
  const WineShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3, // Number of tabs
        child: WineShopHomePage(),
      ),
    );
  }
}

class WineShopHomePage extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;
  final globalInfo = GlobalInfo.instance;
  WineShopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wine Shop App'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Insert Items'),
            Tab(text: 'List Items'),
            Tab(text: 'Order Items'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // Content for the first tab (Insert Item)
          ItemInsertTab(dbHelper: dbHelper, globalInfo: globalInfo),
          // Content for the second tab (List Items)
          ItemListTab(dbHelper: dbHelper, globalInfo: globalInfo),
          // Content for the third tab (Order Items)
          ItemOrderTab(dbHelper: dbHelper, globalInfo: globalInfo),
        ],
      ),
    );
  }
}
