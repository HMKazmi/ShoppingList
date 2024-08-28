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
  List<GroceryItem> loadedItems = [];

  void goToNewItem() async {
    final newGrocery = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    setState(() {
      loadedItems.add(newGrocery!);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final List<GroceryItem> groceryItems=[];
    final url = Uri.https(
        "flutter-prep-01-default-rtdb.firebaseio.com", "shopping-list.json");
    final result = await http.get(url);
    final Map<String, dynamic> listData = json.decode(result.body);
    for (final item in listData.entries) {
      final itemCategory = categories.entries.firstWhere((element) =>element.value.categoryTitle==item.value['category'] );

      groceryItems.add(
        GroceryItem(
          id: item.key.toString(),
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: itemCategory.value,
        ),
      );
    }
    setState(() {
      loadedItems=groceryItems;
    });

  }
  // void getData() async {

  // }
  // setState(() {
  // }

  @override
  Widget build(BuildContext context) {
    _loadItems();
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
      body: loadedItems.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              itemCount: loadedItems.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey(loadedItems[index]),
                  onDismissed: (direction) {
                    setState(() {
                      loadedItems.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Grocery item deleted!",
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
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
            ),
    );
  }
}
