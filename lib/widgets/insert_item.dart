import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'item_list_tab.dart';

class ItemInsert extends StatefulWidget {
  static final GlobalKey<ItemInsertState> scaffoldKey = GlobalKey();
  ItemInsert() : super(key: scaffoldKey);

  @override
  ItemInsertState createState() => ItemInsertState();
}

class ItemInsertState extends State<ItemInsert> {
  final dbHelper = DatabaseHelper.instance;
  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  final retrieveItemNameController = TextEditingController();
  double? retrievedPrice;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    itemNameController.dispose();
    itemPriceController.dispose();
    retrieveItemNameController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final originalBytes = await pickedImage.readAsBytes();
      final resizedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minHeight: 400, // Adjust the desired size
        minWidth: 300,
      );
      setState(() {
        _imageBytes = resizedBytes;
      });
    }
  }

  void _insertItem() async {
    final name = itemNameController.text;
    final price = double.tryParse(itemPriceController.text) ?? 0.0;

    if (name.isNotEmpty) {
      final newItem = Item(name: name, price: price, image: _imageBytes);
      await dbHelper.insertItem(newItem);
      itemNameController.clear();
      itemPriceController.clear();
      setState(() {
        _imageBytes = null; // Clear the image after insertion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Database App'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Insert Item'),
              Tab(text: 'List Items'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for the first tab (Insert Item)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  TextField(
                    controller: itemPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Item Price'),
                  ),
                  const SizedBox(height: 4),
                  // Container to adjust the alignment of the displayed image
                  Container(
                      alignment:
                          Alignment.topCenter, // Adjust the alignment as needed
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!)
                          : const SizedBox()),
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Take Picture'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _insertItem,
                    child: const Text('Insert Item'),
                  ),
                ],
              ),
            ),

            // Content for the second tab (List Items)
            ItemListTab(dbHelper: dbHelper),
          ],
        ),
      ),
    );
  }
}
