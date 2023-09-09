import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wine_shop/utils/utils.dart';

class DirListScreen extends StatefulWidget {
  static final GlobalKey<DirListState> scaffoldKey = GlobalKey();
  final Directory dir;
  DirListScreen({required this.dir}) : super(key: scaffoldKey);
  @override
  DirListState createState() => DirListState();
}

class DirListState extends State<DirListScreen> {
  List<FileSystemEntity> _directoryContents = [];

  @override
  void initState() {
    super.initState();
    _loadDirectoryContents();
  }

  Future<void> _loadDirectoryContents() async {
    try {
      final List<FileSystemEntity> contents = await widget.dir.list().toList();

      setState(() {
        _directoryContents = contents;
      });
    } catch (e) {
      if (context.mounted) {
        Utils.usrMsg(context, "Error loading dir content", e.toString());
      }
    }
  }

  Future<void> _deleteFile(FileSystemEntity entity) async {
    try {
      await entity.delete();
      setState(() {
        _directoryContents.remove(entity);
      });
    } catch (e) {
      if (context.mounted) {
        Utils.usrMsg(context, "Error deleting file", e.toString());
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(FileSystemEntity entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Do you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteFile(entity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory Contents'),
      ),
      body: ListView.builder(
        itemCount: _directoryContents.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _directoryContents[index];
          return ListTile(
            title: Text(item.uri.pathSegments.last),
            onTap: () => _showDeleteConfirmationDialog(item),
          );
        },
      ),
    );
  }
}
