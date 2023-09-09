import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';

class EditDeleteScreen extends StatefulWidget {
  static final GlobalKey<EditDeleteScreenState> scaffoldKey = GlobalKey();
  final Item item;

  EditDeleteScreen({required this.item}) : super(key: scaffoldKey);

  @override
  EditDeleteScreenState createState() => EditDeleteScreenState();
}

class EditDeleteScreenState extends State<EditDeleteScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  late Item _item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit/Delete Item')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Item Price'),
            ),
            // Container to adjust the alignment of the displayed image
            Container(
              alignment: Alignment.topCenter, // Adjust the alignment as needed
              child: _item.image != null
                  ? Image.memory(_item.image!)
                  : const SizedBox(), // You can use any empty widget here
            ),
            // Button to take a picture
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updateItem,
              child: const Text('Save Changes'),
            ),
            ElevatedButton(
              onPressed: _deleteItem,
              child: const Text('Delete Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    nameController.text = _item.name;
    priceController.text = _item.price.toString();
  }

  void _deleteItem() async {
    await DatabaseHelper.instance.deleteItem(_item.id);
    if (context.mounted) {
      Navigator.pop(context, true); // Go back to previous screen
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
        _item.image = resizedBytes;
      });
    }
  }

  void _updateItem() async {
    _item.name = nameController.text;
    _item.price = double.tryParse(priceController.text) ?? 0.0;

    if (_item.name.isNotEmpty) {
      await DatabaseHelper.instance.updateItem(_item);
      if (context.mounted) {
        Navigator.pop(context, true); // Go back to previous screen
      }
    }
  }
}
