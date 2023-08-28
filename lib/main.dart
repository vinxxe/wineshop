import 'package:flutter/material.dart';
import 'widgets/insert_item.dart';

void main() {
  runApp(const WineShopApp());
}

class WineShopApp extends StatelessWidget {
  const WineShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine Shop App',
      home: ItemInsert(),
    );
  }
}
