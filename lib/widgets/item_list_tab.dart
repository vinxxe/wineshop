import 'dart:io'; // Import the dart:io package for File class
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/database/db_helper.dart';
import 'edit_delete_screen.dart';
import 'package:wine_shop/utils/utils.dart';

class ItemListTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  static final GlobalKey<ItemListTabState> scaffoldKey = GlobalKey();

  ItemListTab({required this.dbHelper}) : super(key: scaffoldKey);

  @override
  ItemListTabState createState() => ItemListTabState();
}

class ItemListTabState extends State<ItemListTab> {
  bool shouldUpdateList = false; // State variable to track update
  String _filterKeyword = ''; // Initialize with an empty string

  Future<String> getExtDir() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      // Handle other platforms or throw an error
      throw UnsupportedError('Unsupported platform');
    }

    if (dir != null) {
      return dir.path;
    } else {
      return '';
    }
  }

  Future<void> loadCSVFileIntoDatabase(File file) async {
    final String csvString = await file.readAsString();
    final List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(csvString);

    // Assuming the CSV file format is [name, price]
    for (final row in csvTable) {
      final name = row[0].toString();
      final price = double.tryParse(row[1].toString()) ?? 0.0;

      if (name.isNotEmpty) {
        final newItem = Item(name: name, price: price, image: null);
        await widget.dbHelper.insertItem(newItem);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV file loaded into database')),
      );
    }

    setState(() {
      shouldUpdateList = true;
    });
  }

  Future<void> exportDatabaseToCSV(String fileName) async {
    final directory = await getExtDir();
    final file = File('$directory/$fileName.csv');

    final items = await widget.dbHelper.getAllItemsOrderedByName();
    final csvRows = items.map((item) => [item.name, item.price]).toList();
    final csvString = const ListToCsvConverter().convert(csvRows);

    await file.writeAsString(csvString);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported to ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Item List')),
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
                      final shouldUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditDeleteScreen(item: item)),
                      );
                      if (shouldUpdate == true) {
                        setState(() {
                          shouldUpdateList = true;
                        });
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
                heroTag: "ht1",
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
                heroTag: "ht2",
                onPressed: () {
                  setState(() {
                    _filterKeyword = ''; // Clear the filter keyword
                  });
                },
                tooltip: 'Clear Filter',
                child: const Icon(Icons.clear),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht3",
                onPressed: () async {
                  final File? file =
                      await Utils.pickCSVFile(); // Use your utility method
                  if (file != null) {
                    await loadCSVFileIntoDatabase(file);
                  }
                },
                tooltip: 'Load CSV',
                child: const Icon(Icons.file_upload),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht4",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final exportFileNameController = TextEditingController();
                      return AlertDialog(
                        title: const Text('Export Database to CSV'),
                        content: TextField(
                          controller: exportFileNameController,
                          decoration:
                              const InputDecoration(labelText: 'File Name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final fileName = exportFileNameController.text;
                              if (fileName.isNotEmpty) {
                                exportDatabaseToCSV(fileName);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Export'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.file_download), // Use a suitable icon
              )
            ])
/*
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                // Implement navigation to other tabs if needed
              },
              icon: Icon(Icons.tab),
            ),
            IconButton(
              onPressed: () {
                // Implement navigation to other tabs if needed
              },
              icon: Icon(Icons.tab),
            ),
          ],
        ),
      ),
*/
        );
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

    // for (final item in filteredItems) {
    //   if (item.image != null) {
    //     item.image = await widget.dbHelper.getItemImage(item.id);
    //   }
    // }

    return filteredItems;
  }
}
