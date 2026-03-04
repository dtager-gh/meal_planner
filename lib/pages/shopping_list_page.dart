import 'package:flutter/material.dart';
import '../services/kroger_api_service.dart';
import '../pages/kroger_integration_page.dart';
import '../config/kroger_config.dart';


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


  // NEW: Navigate to Kroger integration
  void _openKrogerIntegration() {
    if (widget.shoppingList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping list is empty')),
      );
      return;
    }

    // Convert your Map<String, int> to List<String> for Kroger
    final ingredients = widget.shoppingList.keys.toList();

    // Initialize Kroger service
    final krogerApi = KrogerApiService(
      clientId: KrogerConfig.clientId,
      clientSecret: KrogerConfig.clientSecret,
      redirectUri: KrogerConfig.redirectUri,
    );

    // Navigate to Kroger page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KrogerIntegrationPage(
          krogerService: krogerApi,
          ingredients: ingredients,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: Column(
        children: [
          // Scrollable list of shopping items
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: widget.shoppingList.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Quantity: ${entry.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
          ),

          // Kroger button at the bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Kroger Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: widget.shoppingList.isEmpty ? null : _openKrogerIntegration,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}