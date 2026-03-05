import 'package:flutter/material.dart';
import '../services/kroger_api_service.dart';
import '../pages/kroger_integration_page.dart';
import '../config/kroger_config.dart';

class ShoppingListPage extends StatefulWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late Map<String, bool> _includeInCart;

  @override
  void initState() {
    super.initState();
    _includeInCart = {for (var key in widget.shoppingList.keys) key: true};
  }

  void _openKrogerIntegration() {
    final ingredients = widget.shoppingList.entries
        .where((e) => (_includeInCart[e.key] ?? true) == true)
        .map((e) => e.key)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected to add')),
      );
      return;
    }

    final krogerApi = KrogerApiService(
      clientId: KrogerConfig.clientId,
      clientSecret: KrogerConfig.clientSecret,
      redirectUri: KrogerConfig.redirectUri,
    );

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
    final hasIncludedItems = widget.shoppingList.keys
        .any((k) => (_includeInCart[k] ?? true) == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: Column(
        children: [
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
                      value: _includeInCart[entry.key] ?? true,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeInCart[entry.key] = value ?? true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

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
                  onPressed: hasIncludedItems ? _openKrogerIntegration : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}