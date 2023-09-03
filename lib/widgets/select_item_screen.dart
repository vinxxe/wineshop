import 'dart:typed_data';

import 'package:flutter/material.dart';
//import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';

class SelectItemScreen extends StatefulWidget {
  static final GlobalKey<SelectItemScreenState> scaffoldKey = GlobalKey();
  final Item item;

  SelectItemScreen({required this.item}) : super(key: scaffoldKey);

  @override
  SelectItemScreenState createState() => SelectItemScreenState();
}

class SelectItemScreenState extends State<SelectItemScreen> {
  int itemCount = 1;
  final TextEditingController countController = TextEditingController();
  Uint8List? _imageBytes;

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
              '${widget.item.name} - \u20AC ${widget.item.price}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20.0),
            ),
            // Container to adjust the alignment of the displayed image
            Container(
              alignment: Alignment.topCenter, // Adjust the alignment as needed
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : (widget.item.image != null
                      ? Image.memory(widget.item.image!)
                      : const SizedBox()), // You can use any empty widget here
            ),
            Row(
                // Align items horizontally in the center
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (itemCount > 1) {
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
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    countController.text = '$itemCount';
  }
}
