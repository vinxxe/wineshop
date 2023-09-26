import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  // Prevent instantiation by making the constructor private
  const Utils._();

  static Future<void> createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
  }

  static Future<bool> doesDirectoryExist(String path) async {
    final directory = Directory(path);
    return await directory.exists();
  }

  static Future<String> getExtDir() async {
//    PermissionStatus status = await Permission.manageExternalStorage.status;
//    if (!status.isGranted) {
//      do {
//        await Permission.manageExternalStorage.request();
//        status = await Permission.manageExternalStorage.status;
//      } while (!status.isGranted);
//    }

    String? dir = await FilePicker.platform.getDirectoryPath();

    if (dir != null) {
      return dir;
    } else {
      return '';
    }
  }

  static Future<String?> pickCSVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
    }
  }

  static void usrMsg(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      // Prevent user from closing dialog with back button or tapping outside
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              //Close the dialog
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
