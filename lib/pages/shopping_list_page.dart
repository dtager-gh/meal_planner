import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/kroger_api_service.dart';
import '../pages/kroger_integration_page.dart';
import '../pages/product_picker_page.dart';
import '../config/kroger_config.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ShoppingListPage extends StatefulWidget {
  final Map<String, int> shoppingList;
  const ShoppingListPage({super.key, required this.shoppingList});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}


class _ShoppingListPageState extends State<ShoppingListPage> {
  late Map<String, bool> _includeInCart;
  late Map<String, int> _cartQty;

  KrogerStore? _krogerStore;
  late final KrogerApiService _krogerApi;

  @override
  void initState() {
    super.initState();

    _includeInCart = {for (var key in widget.shoppingList.keys) key: true};

    _cartQty = Map<String, int>.from(widget.shoppingList);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('No logged-in user. Cannot create KrogerApiService without userKey.');
    }

    _krogerApi = KrogerApiService(
      userKey: uid,
      clientId: KrogerConfig.clientId,
      clientSecret: KrogerConfig.clientSecret,
      redirectUri: KrogerConfig.redirectUri,
    );
  }

  String _upcKey(String ingredient) => '${_krogerApi.userKey}|$ingredient';

  void _incQty(String ingredient) {
    setState(() {
      final current = _cartQty[ingredient] ?? 1;
      _cartQty[ingredient] = current + 1;
    });
  }

  void _decQty(String ingredient) {
    setState(() {
      final current = _cartQty[ingredient] ?? 1;
      final next = current - 1;
      _cartQty[ingredient] = next < 1 ? 1 : next; // clamp to 1
    });
  }

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

  Future<void> _chooseProduct(String ingredient) async {
    if (_krogerStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to Kroger and choose a store first')),
      );
      return;
    }

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

    final box = Hive.box<String>('krogerSelectedUpcByUid');
    await box.put('${_krogerApi.userKey}|$ingredient', picked.upc);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: ${picked.description}')),
    );
  }

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

    final box = Hive.box<String>('krogerSelectedUpcByUid');

    int added = 0;
    int skipped = 0;
    int failed = 0;

    for (final entry in widget.shoppingList.entries) {
      final ingredient = entry.key;
      final qty = _cartQty[ingredient] ?? entry.value;


      if ((_includeInCart[ingredient] ?? true) != true) {
        skipped++;
        continue;
      }


      final upc = box.get('${_krogerApi.userKey}|$ingredient');
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
    final selectedBox = Hive.box<String>('krogerSelectedUpcByUid');
    final hasAtLeastOneSelected = widget.shoppingList.keys.any((k) {
      final included = (_includeInCart[k] ?? true) == true;
      final upc = selectedBox.get(_upcKey(k));
      return included && upc != null && upc.isNotEmpty;
    });

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
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: widget.shoppingList.entries.map((entry) {
                    final ingredient = entry.key;
                    final qty = _cartQty[ingredient] ?? entry.value;

                    final upc = selectedBox.get(_upcKey(ingredient));
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Qty:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: included ? () => _decQty(ingredient) : null,
                                  tooltip: 'Decrease',
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: included ? () => _incQty(ingredient) : null,
                                  tooltip: 'Increase',
                                ),
                              ],
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