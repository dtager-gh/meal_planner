import 'package:flutter/material.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';

class ShoppingListPage extends StatefulWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late Map<String, bool> _purchased;

  @override
  void initState() {
    super.initState();
    // Initialize all items as not purchased
    _purchased = {for (var key in widget.shoppingList.keys) key: false};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: widget.shoppingList.entries.map((entry) {
          return CheckboxListTile(
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Text('Quantity: ${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold), ),
            value: _purchased[entry.key],
            onChanged: (bool? value) {
              setState(() {
                _purchased[entry.key] = value ?? false;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
