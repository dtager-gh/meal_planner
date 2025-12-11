// lib/pages/kroger_integration_page.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/kroger_api_service.dart';

// Main integration page
class KrogerIntegrationPage extends StatefulWidget {
  final KrogerApiService krogerService;
  final List<String> ingredients; // Your meal plan ingredients

  const KrogerIntegrationPage({
    Key? key,
    required this.krogerService,
    required this.ingredients,
  }) : super(key: key);

  @override
  State<KrogerIntegrationPage> createState() => _KrogerIntegrationPageState();
}

class _KrogerIntegrationPageState extends State<KrogerIntegrationPage> {
  KrogerStore? _selectedStore;
  Map<String, KrogerProduct?> _matchedProducts = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await widget.krogerService.loadStoredToken();
    if (!isAuth) {
      _startOAuth();
    } else {
      _loadNearbyStores();
    }
  }

  void _startOAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KrogerOAuthPage(
          krogerService: widget.krogerService,
          onSuccess: () {
            Navigator.pop(context);
            _loadNearbyStores();
          },
        ),
      ),
    );
  }

  Future<void> _loadNearbyStores() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Get user's actual location using geolocator package
      // For now using Atlanta coordinates as example
      final stores = await widget.krogerService.searchStores(
        latitude: 33.7490,
        longitude: -84.3880,
        radiusMiles: 10,
      );

      if (stores.isNotEmpty && mounted) {
        setState(() {
          _selectedStore = stores.first;
        });
        _searchForIngredients();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stores: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchForIngredients() async {
    if (_selectedStore == null) return;

    setState(() => _isLoading = true);

    for (final ingredient in widget.ingredients) {
      try {
        final products = await widget.krogerService.searchProducts(
          searchTerm: ingredient,
          locationId: _selectedStore!.locationId,
          limit: 5,
        );

        setState(() {
          _matchedProducts[ingredient] = products.isNotEmpty ? products.first : null;
        });
      } catch (e) {
        print('Error searching for $ingredient: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addAllToCart() async {
    int successCount = 0;
    int failCount = 0;

    for (final entry in _matchedProducts.entries) {
      if (entry.value != null) {
        try {
          final success = await widget.krogerService.addToCart(
            productId: entry.value!.upc,
            quantity: 1,
          );
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          print('Error adding ${entry.key} to cart: $e');
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $successCount items to cart${failCount > 0 ? ", $failCount failed" : ""}'),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kroger Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.krogerService.logout();
              _startOAuth();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_selectedStore != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.store),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStore!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_selectedStore!.address}, ${_selectedStore!.city}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show store picker dialog
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _matchedProducts.isEmpty
                ? const Center(child: Text('No products matched'))
                : ListView.builder(
              itemCount: _matchedProducts.length,
              itemBuilder: (context, index) {
                final entry = _matchedProducts.entries.elementAt(index);
                final ingredient = entry.key;
                final product = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: product?.imageUrl != null
                        ? Image.network(
                      product!.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                    )
                        : const Icon(Icons.shopping_basket),
                    title: Text(ingredient),
                    subtitle: product != null
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${product.brand} - ${product.size}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (product.price != null)
                          Text(
                            '\$${product.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    )
                        : const Text('No match found'),
                    trailing: product != null
                        ? IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () async {
                        final success = await widget.krogerService.addToCart(
                          productId: product.upc,
                          quantity: 1,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Added to cart'
                                    : 'Failed to add to cart',
                              ),
                            ),
                          );
                        }
                      },
                    )
                        : const Icon(Icons.error_outline),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add All to Kroger Cart'),
                  onPressed: _matchedProducts.values.any((p) => p != null)
                      ? _addAllToCart
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// OAuth WebView Page
class KrogerOAuthPage extends StatefulWidget {
  final KrogerApiService krogerService;
  final VoidCallback onSuccess;

  const KrogerOAuthPage({
    Key? key,
    required this.krogerService,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<KrogerOAuthPage> createState() => _KrogerOAuthPageState();
}

class _KrogerOAuthPageState extends State<KrogerOAuthPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            // Check if this is the redirect with the authorization code
            if (request.url.startsWith(widget.krogerService.redirectUri)) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.krogerService.getAuthorizationUrl()));
  }

  Future<void> _handleRedirect(String url) async {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];

    if (code != null) {
      final success = await widget.krogerService.exchangeCodeForToken(code);
      if (success && mounted) {
        widget.onSuccess();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in to Kroger'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}