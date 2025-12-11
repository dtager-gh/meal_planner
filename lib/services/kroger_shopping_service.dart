// lib/services/kroger_shopping_service.dart
// This bridges YOUR existing shopping list service with Kroger API

import 'kroger_api_service.dart';

class KrogerShoppingService {
  final KrogerApiService _krogerApi;
  KrogerStore? selectedStore;

  KrogerShoppingService(this._krogerApi);

  // Convert your shopping list items to Kroger products
  Future<Map<String, KrogerProduct?>> matchIngredientsToProducts({
    required List<String> ingredients,
    required String storeLocationId,
  }) async {
    final Map<String, KrogerProduct?> matches = {};

    for (final ingredient in ingredients) {
      try {
        final products = await _krogerApi.searchProducts(
          searchTerm: _cleanIngredient(ingredient),
          locationId: storeLocationId,
          limit: 3,
        );

        matches[ingredient] = products.isNotEmpty ? products.first : null;
      } catch (e) {
        print('Error matching ingredient "$ingredient": $e');
        matches[ingredient] = null;
      }
    }

    return matches;
  }

  // Clean up ingredient text for better search results
  String _cleanIngredient(String ingredient) {
    // Remove quantities and measurements
    final cleaned = ingredient
        .replaceAll(RegExp(r'\d+(\.\d+)?\s*(cups?|tbsp?|tsp?|oz|lbs?|grams?|kg)'), '')
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'[(),]'), '')
        .trim();

    // Take first 2-3 words for better search
    final words = cleaned.split(' ');
    return words.take(3).join(' ');
  }

  // Add multiple items to cart at once
  Future<AddToCartResult> addIngredientsToCart(
      Map<String, KrogerProduct?> matchedProducts,
      ) async {
    int successCount = 0;
    int failCount = 0;
    List<String> failedItems = [];

    for (final entry in matchedProducts.entries) {
      if (entry.value != null) {
        try {
          final success = await _krogerApi.addToCart(
            productId: entry.value!.upc,
            quantity: 1,
          );

          if (success) {
            successCount++;
          } else {
            failCount++;
            failedItems.add(entry.key);
          }
        } catch (e) {
          failCount++;
          failedItems.add(entry.key);
        }
      }
    }

    return AddToCartResult(
      successCount: successCount,
      failCount: failCount,
      failedItems: failedItems,
    );
  }

  // Get nearby Kroger stores
  Future<List<KrogerStore>> getNearbyStores({
    required double latitude,
    required double longitude,
  }) async {
    return await _krogerApi.searchStores(
      latitude: latitude,
      longitude: longitude,
      radiusMiles: 25,
    );
  }

  // Check if user is authenticated with Kroger
  Future<bool> isAuthenticated() async {
    return await _krogerApi.loadStoredToken();
  }

  bool get hasSelectedStore => selectedStore != null;
}

// Result class
class AddToCartResult {
  final int successCount;
  final int failCount;
  final List<String> failedItems;

  AddToCartResult({
    required this.successCount,
    required this.failCount,
    required this.failedItems,
  });

  bool get hasFailures => failCount > 0;
  bool get allSucceeded => failCount == 0 && successCount > 0;
}