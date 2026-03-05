import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/kroger_api_service.dart';
import '../pages/kroger_integration_page.dart';
import '../pages/product_picker_page.dart';
import '../config/kroger_config.dart';

// This screen expects a shopping list sent into it.
// It's a StatefulWidget because items can be checked/unchecked.
class ShoppingListPage extends StatefulWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

// This stores whether each item should be included in the Kroger cart
class _ShoppingListPageState extends State<ShoppingListPage> {
  late Map<String, bool> _includeInCart;

  KrogerStore? _krogerStore;
  late final KrogerApiService _krogerApi;

  @override
  void initState() {
    super.initState();

    _includeInCart = {for (var key in widget.shoppingList.keys) key: true};

    _krogerApi = KrogerApiService(
      clientId: KrogerConfig.clientId,
      clientSecret: KrogerConfig.clientSecret,
      redirectUri: KrogerConfig.redirectUri,
    );
  }

  // Step 3: Connect to Kroger + pick store (returns KrogerStore)
  Future<void> _openKrogerIntegration() async {
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

    final store = await Navigator.push<KrogerStore>(
      context,
      MaterialPageRoute(
        builder: (context) => KrogerIntegrationPage(
          krogerService: _krogerApi,
          ingredients: ingredients,
        ),
      ),
    );

    if (store != null) {
      setState(() {
        _krogerStore = store;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${store.name}')),
      );
    }
  }

  // Step 5 (part): Choose a product for a given ingredient (stores UPC in Hive)
  Future<void> _chooseProduct(String ingredient) async {
    if (_krogerStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to Kroger and choose a store first')),
      );
      return;
    }

    // Ensure token is available (should be after auth, but safe)
    await _krogerApi.loadStoredToken();

    final picked = await Navigator.push<KrogerProduct>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductPickerPage(
          krogerService: _krogerApi,
          ingredient: ingredient,
          locationId: _krogerStore!.locationId,
        ),
      ),
    );

    if (picked == null) return;

    final box = Hive.box<String>('krogerSelectedUpcByIngredient');
    await box.put(ingredient, picked.upc);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: ${picked.description}')),
    );
  }

  // Step 5 (part): Add ONLY included + selected items to cart
  Future<void> _addSelectedToKrogerCart() async {
    if (_krogerStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to Kroger and choose a store first')),
      );
      return;
    }

    final authed = await _krogerApi.loadStoredToken();
    if (!authed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to Kroger again')),
      );
      return;
    }

    final box = Hive.box<String>('krogerSelectedUpcByIngredient');

    int added = 0;
    int skipped = 0;
    int failed = 0;

    for (final entry in widget.shoppingList.entries) {
      final ingredient = entry.key;
      final qty = entry.value;

      // Must be included
      if ((_includeInCart[ingredient] ?? true) != true) {
        skipped++;
        continue;
      }

      // Must have a chosen UPC
      final upc = box.get(ingredient);
      if (upc == null || upc.isEmpty) {
        skipped++;
        continue;
      }

      try {
        final ok = await _krogerApi.addToCart(productId: upc, quantity: qty);
        if (ok) {
          added++;
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $added • Skipped $skipped • Failed $failed'),
        backgroundColor: failed > 0 ? Colors.orange : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Enable "Add Selected" only if at least one included item has a selected UPC
    final selectedBox = Hive.box<String>('krogerSelectedUpcByIngredient');
    final hasAtLeastOneSelected = widget.shoppingList.keys.any((k) {
      final included = (_includeInCart[k] ?? true) == true;
      final upc = selectedBox.get(k);
      return included && upc != null && upc.isNotEmpty;
    });

    // Enable "Connect" only if at least one item is included
    final hasIncludedItems = widget.shoppingList.keys
        .any((k) => (_includeInCart[k] ?? true) == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (_krogerStore != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _krogerStore!.name,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
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
                    final ingredient = entry.key;
                    final qty = entry.value;

                    final upc = selectedBox.get(ingredient);
                    final included = _includeInCart[ingredient] ?? true;

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: included,
                          onChanged: (bool? value) {
                            setState(() {
                              _includeInCart[ingredient] = value ?? true;
                            });
                          },
                        ),
                        title: Text(
                          ingredient,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity: $qty',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (upc != null && upc.isNotEmpty)
                              Text(
                                'Selected UPC: $upc',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: included ? () => _chooseProduct(ingredient) : null,
                          child: const Text('Choose'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Bottom action bar
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.link),
                      label: Text(_krogerStore == null ? 'Connect to Kroger' : 'Change Kroger Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: hasIncludedItems ? _openKrogerIntegration : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add Selected to Kroger Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: hasAtLeastOneSelected ? _addSelectedToKrogerCart : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}