import 'package:flutter/material.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';


//This screen expects a shopping list sent into it.
//It's a StatefulWidget because items can be checked/unchecked.
class ShoppingListPage extends StatefulWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}


//This creates a second map to store whether each item has been purchased
class _ShoppingListPageState extends State<ShoppingListPage> {
  late Map<String, bool> _purchased;


  //This runs one time only when the page opens.
  // It creates a Map
  //All checkboxes start unchecked
  @override
  void initState() {
    super.initState();

    _purchased = {for (var key in widget.shoppingList.keys) key: false};
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),//AppBar with title: “Shopping List”

      //Creates a scrollable list.
      //It loops through every item in the shopping list map.
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: widget.shoppingList.entries.map((entry) {


              //Item name (bold)
              // Quantity shown under it
              // A checkbox
              // When the user taps the checkbox
              // It updates _purchased[entry.key]
              // The screen refreshes with setState(() {})
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
        ),
      ),
    );
  }
}
