import 'package:flutter/material.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';


class ShoppingListPage extends StatelessWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: shoppingList.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Text(entry.value.toString()),
          );
        }).toList(),
      ),
    );
  }
}