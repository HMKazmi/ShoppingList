import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool _isLoading = true;
  List<GroceryItem> loadedItems = [];

  void goToNewItem() async {
    final newGrocery = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    if (newGrocery == null) {
      return;
    }
    setState(() {
      loadedItems.add(newGrocery);
    });
    _isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  String? errorMsg;
  void _loadItems() async {
    final List<GroceryItem> groceryItems = [];
    final url = Uri.https(
        "flutter-prep-01-default-rtdb.firebaseio.com", "shopping-list.json");
    try {
      final result = await http.get(url);
      if (result.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (result.statusCode >= 400) {
        setState(() {
          errorMsg = "Error 404: Failed to load items. \nPlease try later.";
        });
      }
      final Map<String, dynamic> listData = json.decode(result.body);
      for (final item in listData.entries) {
        final itemCategory = categories.entries.firstWhere(
            (element) => element.value.categoryTitle == item.value['category']);

        groceryItems.add(
          GroceryItem(
            id: item.key.toString(),
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: itemCategory.value,
          ),
        );
      }
    } catch (error) {

      setState(() {
        errorMsg = "Something went wrong. \nPlease try again later.";
      });
      return;
    }
    setState(() {
      loadedItems = groceryItems;
    });
    _isLoading = false;
  }

  void _removeItem(item) async {
    int _itemIndex = loadedItems.indexOf(item);
    setState(() {
      loadedItems.removeAt(_itemIndex);
    });

    final url = Uri.https("flutter-prep-01-default-rtdb.firebaseio.com",
        "shopping-list/${item.id}.json");

    final result = await http.delete(url);
    if (result.statusCode >= 400) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Error ${result.statusCode}: Failed to delete selected item."),
          ),
        );
        loadedItems.insert(_itemIndex, item);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Deleted selected item."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // _loadItems();
    var bodyWidget;
    if (loadedItems.isEmpty) {
      bodyWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Uh oh... No Groceries Found!",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "Click the add + button in top right to add one.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ],
        ),
      );
    } else {
      bodyWidget = ListView.builder(
        itemCount: loadedItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(loadedItems[index]),
            onDismissed: (direction) {
              _removeItem(loadedItems[index]);
            },
            child: ListTile(
              leading: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: loadedItems[index].category.categoryColor),
              ),
              title: Text(
                loadedItems[index].name,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              trailing: Text(
                loadedItems[index].quantity.toString(),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          );
        },
      );
    }

    if (_isLoading) {
      bodyWidget = const Center(
        child: CircularProgressIndicator(),
      );
      if (!(errorMsg == null)) {
        bodyWidget = Center(
          child: Text(
            errorMsg!,
            style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Container(
            margin: const EdgeInsets.only(top: 20),
            child: Text(
              "Your Groceries",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          actions: [IconButton(onPressed: goToNewItem, icon: Icon(Icons.add))],
        ),
        body: bodyWidget);
  }
}
