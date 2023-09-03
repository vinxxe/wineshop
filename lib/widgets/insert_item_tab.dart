import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/utils/utils.dart';
import 'package:wine_shop/models/global_info.dart';

class ItemInsertTab extends StatefulWidget {
  static final GlobalKey<ItemInsertState> scaffoldKey = GlobalKey();
  final DatabaseHelper dbHelper;
  final GlobalInfo     globalInfo;

  ItemInsertTab({required this.dbHelper, required this.globalInfo}) : super(key: scaffoldKey);

  @override
  ItemInsertState createState() => ItemInsertState();
}

class ItemInsertState extends State<ItemInsertTab> {
  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(8.0), // Add margin of 8.0 pixels on all sides
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
    );
  }

  @override
  void dispose() {
    itemNameController.dispose();
    itemPriceController.dispose();
    super.dispose();
  }

  void _insertItem() async {
    final name = itemNameController.text;
    final price = double.tryParse(itemPriceController.text) ?? 0.0;

    if (name.isNotEmpty) {
      final newItem = Item(name: name, price: price, image: _imageBytes);
      try {
        await widget.dbHelper.insertItem(newItem);
        itemNameController.clear();
        itemPriceController.clear();
        setState(() {
          _imageBytes = null; // Clear the image after insertion
        });
      } catch (e) {
        if (context.mounted) {
          Utils.usrMsg(context, "DB exception",
              "Maybe the item's name ${newItem.name} is already present");
        }
      }
    }
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
}
