import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final List<GroceryItem> groceryList = [];

  void goToNewItem() async {
    final newGrocery = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    setState(() {
      groceryList.add(newGrocery!);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: groceryList.length == 0
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
              itemCount: groceryList.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey(groceryList[index]),
                  onDismissed: (direction) {
                    setState(() {
                      groceryList.removeAt(index);
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
                          color: groceryList[index].category.categoryColor),
                    ),
                    title: Text(
                      groceryList[index].name,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    trailing: Text(
                      groceryList[index].quantity.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
