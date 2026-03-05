// lib/pages/kroger_integration_page.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/kroger_api_service.dart';

// Main integration page (Step 4: connect + choose store, no auto-matching, no add-all)
class KrogerIntegrationPage extends StatefulWidget {
  final KrogerApiService krogerService;

  // Keeping this param so you don't have to refactor call sites yet,
  // but Step 4 no longer uses it.
  final List<String> ingredients;

  const KrogerIntegrationPage({
    super.key,
    required this.krogerService,
    required this.ingredients,
  });

  @override
  State<KrogerIntegrationPage> createState() => _KrogerIntegrationPageState();
}

class _KrogerIntegrationPageState extends State<KrogerIntegrationPage> {
  KrogerStore? _selectedStore;
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
// Using North Augusta, SC coordinates
      final stores = await widget.krogerService.searchStores(
        latitude: 33.5018,
        longitude: -81.9651,
        radiusMiles: 20,
      );

      if (!mounted) return;

      if (stores.isNotEmpty) {
        setState(() {
          _selectedStore = stores.first;
        });
      } else {
        setState(() {
          _selectedStore = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stores: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kroger Connection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.krogerService.logout();
              if (mounted) _startOAuth();
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
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedStore);
                    },
                    child: const Text('Use this store'),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'No store found nearby.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _loadNearbyStores,
                  ),
                ],
              ),
            ),

          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Connected to Kroger.\n\nNext, you will choose a product for each ingredient from your shopping list.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// OAuth WebView Page (unchanged)
class KrogerOAuthPage extends StatefulWidget {
  final KrogerApiService krogerService;
  final VoidCallback onSuccess;

  const KrogerOAuthPage({
    super.key,
    required this.krogerService,
    required this.onSuccess,
  });

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

  Future<void> _initializeWebView() async {
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
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