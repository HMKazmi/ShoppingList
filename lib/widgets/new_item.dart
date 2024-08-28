import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
// import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables];

  void _onSaved() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          "flutter-prep-01-default-rtdb.firebaseio.com", "shopping-list.json");
      final result=await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory!.categoryTitle,
          },
        ),
      );
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
      print(result.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Item Form"),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text("Name")),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text.';
                  } else if (value.trim().length > 50) {
                    return 'Name too long (must be lesser than 50 characters).';
                  } else if (value.trim().length <= 1) {
                    return 'Name must be at least 2 characters.';
                  }
                  return null;
                },
                onChanged: (value) {
                  _enteredName = value;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(label: Text("Quantity")),
                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! > 50 ||
                            int.tryParse(value)! <= 0) {
                          return 'Please enter quantity as a number between 1 and 50.';
                        }
                        return null;
                      },
                      initialValue: "1",
                      onChanged: (value) {
                        _enteredQuantity = int.parse(value);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration:
                          const InputDecoration(label: Text("Category")),
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                      color: category.value.categoryColor),
                                ),
                                const SizedBox(width: 10),
                                Text(category.value.categoryTitle),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _onSaved();
                    },
                    child: const Text("Add Item"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
