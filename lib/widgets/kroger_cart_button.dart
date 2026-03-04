// lib/widgets/kroger_cart_button.dart
// Add this button to your shopping list screen

import 'package:flutter/material.dart';
import '../services/kroger_api_service.dart';
import '../config/kroger_config.dart';
import '../pages/kroger_integration_page.dart';

class KrogerCartButton extends StatelessWidget {
  final List<String> shoppingListItems;

  const KrogerCartButton({
    super.key,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.shopping_cart),
      label: const Text('Add to Kroger Cart'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: shoppingListItems.isEmpty
          ? null
          : () => _openKrogerIntegration(context),
    );
  }

  void _openKrogerIntegration(BuildContext context) {
    // Initialize Kroger service
    final krogerApi = KrogerApiService(
      clientId: KrogerConfig.clientId,
      clientSecret: KrogerConfig.clientSecret,
      redirectUri: KrogerConfig.redirectUri,
    );

    // Navigate to Kroger integration page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KrogerIntegrationPage(
          krogerService: krogerApi,
          ingredients: shoppingListItems,
        ),
      ),
    );
  }
}