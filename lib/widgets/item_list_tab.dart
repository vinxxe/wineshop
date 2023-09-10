import 'dart:io'; // Import the dart:io package for File class

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:wine_shop/database/db_helper.dart';
import 'package:wine_shop/models/item.dart';
import 'package:wine_shop/utils/utils.dart';
import 'package:wine_shop/models/global_info.dart';

import 'edit_delete_screen.dart';

class ItemListTab extends StatefulWidget {
  static final GlobalKey<ItemListTabState> scaffoldKey = GlobalKey();
  final DatabaseHelper dbHelper;
  final GlobalInfo globalInfo;

  ItemListTab({required this.dbHelper, required this.globalInfo})
      : super(key: scaffoldKey);

  @override
  ItemListTabState createState() => ItemListTabState();
}

class ItemListTabState extends State<ItemListTab> {
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
                  widget.globalInfo.workingFolder = await Utils.getExtDir();
                },
                tooltip: 'Set the working dir',
                child: const Icon(Icons.folder_shared),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht4",
                onPressed: () async {
                  if (widget.globalInfo.workingFolder.isNotEmpty) {
                    final String? filePath = await Utils.pickCSVFile();
                    if (filePath != null) {
                      await loadCSVFileIntoDatabase(filePath);
                    }
                  } else {
                    if (context.mounted) {
                      Utils.usrMsg(
                          context, "DIR ERROR", "no working dir chosen");
                    }
                  }
                },
                tooltip: 'Load CSV',
                child: const Icon(Icons.file_upload),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "ht5",
                onPressed: () {
                  if (widget.globalInfo.workingFolder.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final exportFileNameController =
                            TextEditingController();
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
                  } else {
                    if (context.mounted) {
                      Utils.usrMsg(
                          context, "DIR ERROR", "no working dir chosen");
                    }
                  }
                },
                child: const Icon(Icons.file_download), // Use a suitable icon
              )
            ]));
  }

  Future<void> exportDatabaseToCSV(String fileName) async {
    final file = File('${widget.globalInfo.workingFolder}/$fileName.csv');

    final items = await widget.dbHelper.getAllItemsOrderedByName();
    final attributeNames = [
      'Name',
      'Price',
      'Type',
      'Country',
      'Region',
      'Vintage',
      'Stock',
      'Sold',
      'Producer',
      'Description'
    ];

    final csvRows = [
      attributeNames, // Add attribute names as the first row
      ...items.map((item) => [
            item.name,
            item.price,
            item.type.id,
            item.country.id,
            item.region.id,
            item.vintage,
            item.stock,
            item.sold,
            item.producer,
            item.description
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvRows);

    await file.writeAsString(csvString);
    await Utils.createDirectoryIfNotExists(
        '${widget.globalInfo.workingFolder}/$fileName');

    for (var item in items) {
      if (item.image != null) {
        final file = File(
            '${widget.globalInfo.workingFolder}/$fileName/${item.name}.jpg');
        await file.writeAsBytes(item.image!);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported to ${file.path}')),
      );
    }
  }

  Future<void> loadCSVFileIntoDatabase(String filePath) async {
    final basename = path.basename(filePath);
    final dirbasename = path.basenameWithoutExtension(basename);

    final file = File('${widget.globalInfo.workingFolder}/$basename');
    final String csvString = await file.readAsString();
    final List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(csvString);
    bool dirExists = false;

    if (await Utils.doesDirectoryExist(
        '${widget.globalInfo.workingFolder}/$dirbasename')) {
      dirExists = true;
    }

    // Start processing from the second row (index 1)
    // to skip the attribute names in the first row.
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      final name = row[0].toString();
      final price = double.tryParse(row[1].toString()) ?? 0.0;

      if (name.isNotEmpty) {
        Item newItem = Item(name: name, price: price, image: null);
        try {
          newItem.type =
              ItemExt.getItemType(int.tryParse(row[2].toString()) ?? 0);
          newItem.country =
              CountryExt.getCountry(int.tryParse(row[3].toString()) ?? 0);
          newItem.region =
              RegionExt.getRegion(int.tryParse(row[4].toString()) ?? 0);
          newItem.vintage = int.tryParse(row[5].toString()) ?? 0;
          newItem.stock = int.tryParse(row[6].toString()) ?? 0;
          newItem.sold = int.tryParse(row[7].toString()) ?? 0;
          newItem.producer = int.tryParse(row[8].toString()) ?? 0;
          newItem.description = row[9];
        } catch (e) {
          newItem.type = ItemType.none;
          newItem.country = Country.none;
          newItem.region = Region.none;
          newItem.vintage = 0;
          newItem.stock = 0;
          newItem.sold = 0;
          newItem.producer = await widget.dbHelper.getProducerID('NONE');
          newItem.description = "";
        }

        if (dirExists) {
          final file =
              File('${widget.globalInfo.workingFolder}/$dirbasename/$name.jpg');
          if (await file.exists()) {
            newItem.image = await file.readAsBytes();
          }
        }
        try {
          await widget.dbHelper.insertItem(newItem);
        } catch (e) {
          if (context.mounted) {
            Utils.usrMsg(context, "DB exception", e.toString());
          }
        }
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
