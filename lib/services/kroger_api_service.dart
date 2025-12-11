// lib/services/kroger_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KrogerApiService {
  static const String _baseUrl = 'https://api.kroger.com/v1';
  static const String _authUrl = 'https://api.kroger.com/v1/connect/oauth2';

  // Replace these with your actual credentials
  final String clientId;
  final String clientSecret;
  final String redirectUri;

  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  DateTime? _tokenExpiry;

  KrogerApiService({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
  });

  // OAuth2 Authorization URL
  String getAuthorizationUrl() {
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'product.compact cart.basic:write profile.compact',
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_authUrl/authorize?$queryString';
  }

  // Exchange authorization code for access token
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse('$_authUrl/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        // Store tokens securely
        await _storage.write(key: 'kroger_access_token', value: _accessToken);
        await _storage.write(key: 'kroger_token_expiry', value: _tokenExpiry!.toIso8601String());

        if (data['refresh_token'] != null) {
          await _storage.write(key: 'kroger_refresh_token', value: data['refresh_token']);
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Error exchanging code for token: $e');
      return false;
    }
  }

  // Load stored token
  Future<bool> loadStoredToken() async {
    try {
      _accessToken = await _storage.read(key: 'kroger_access_token');
      final expiryStr = await _storage.read(key: 'kroger_token_expiry');

      if (_accessToken != null && expiryStr != null) {
        _tokenExpiry = DateTime.parse(expiryStr);

        // Check if token is still valid
        if (_tokenExpiry!.isAfter(DateTime.now())) {
          return true;
        } else {
          // Token expired, try to refresh
          return await _refreshToken();
        }
      }
      return false;
    } catch (e) {
      print('Error loading stored token: $e');
      return false;
    }
  }

  // Refresh access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'kroger_refresh_token');
      if (refreshToken == null) return false;

      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse('$_authUrl/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        await _storage.write(key: 'kroger_access_token', value: _accessToken);
        await _storage.write(key: 'kroger_token_expiry', value: _tokenExpiry!.toIso8601String());

        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Ensure we have a valid token before making API calls
  Future<bool> _ensureValidToken() async {
    if (_accessToken == null || _tokenExpiry == null) {
      return await loadStoredToken();
    }

    if (_tokenExpiry!.isBefore(DateTime.now())) {
      return await _refreshToken();
    }

    return true;
  }

  // Search for stores near a location
  Future<List<KrogerStore>> searchStores({
    required double latitude,
    required double longitude,
    int radiusMiles = 10,
  }) async {
    if (!await _ensureValidToken()) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/locations').replace(queryParameters: {
        'filter.lat.near': latitude.toString(),
        'filter.lon.near': longitude.toString(),
        'filter.radiusInMiles': radiusMiles.toString(),
        'filter.limit': '10',
      }),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stores = (data['data'] as List)
          .map((store) => KrogerStore.fromJson(store))
          .toList();
      return stores;
    } else {
      throw Exception('Failed to load stores: ${response.body}');
    }
  }

  // Search for products by term at a specific store
  Future<List<KrogerProduct>> searchProducts({
    required String searchTerm,
    required String locationId,
    int limit = 10,
  }) async {
    if (!await _ensureValidToken()) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/products').replace(queryParameters: {
        'filter.term': searchTerm,
        'filter.locationId': locationId,
        'filter.limit': limit.toString(),
      }),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = (data['data'] as List)
          .map((product) => KrogerProduct.fromJson(product))
          .toList();
      return products;
    } else {
      throw Exception('Failed to search products: ${response.body}');
    }
  }

  // Add item to cart
  Future<bool> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (!await _ensureValidToken()) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/cart/add'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'items': [
          {
            'upc': productId,
            'quantity': quantity,
          }
        ]
      }),
    );

    return response.statusCode == 204 || response.statusCode == 200;
  }

  // Logout and clear tokens
  Future<void> logout() async {
    _accessToken = null;
    _tokenExpiry = null;
    await _storage.delete(key: 'kroger_access_token');
    await _storage.delete(key: 'kroger_token_expiry');
    await _storage.delete(key: 'kroger_refresh_token');
  }

  bool get isAuthenticated => _accessToken != null;
}

// Models
class KrogerStore {
  final String locationId;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;

  KrogerStore({
    required this.locationId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });

  factory KrogerStore.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    final geolocation = json['geolocation'] ?? {};

    return KrogerStore(
      locationId: json['locationId'] ?? '',
      name: json['name'] ?? '',
      address: address['addressLine1'] ?? '',
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      zipCode: address['zipCode'] ?? '',
      latitude: geolocation['latitude']?.toDouble() ?? 0.0,
      longitude: geolocation['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class KrogerProduct {
  final String productId;
  final String upc;
  final String description;
  final String brand;
  final String size;
  final double? price;
  final String? imageUrl;

  KrogerProduct({
    required this.productId,
    required this.upc,
    required this.description,
    required this.brand,
    required this.size,
    this.price,
    this.imageUrl,
  });

  factory KrogerProduct.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    final firstItem = items?.isNotEmpty == true ? items!.first : null;

    final price = firstItem?['price']?['regular'];
    final images = json['images'] as List?;

    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      final firstImage = images.first;
      final sizes = firstImage['sizes'] as List?;
      if (sizes != null && sizes.isNotEmpty) {
        imageUrl = sizes.first['url'] as String?;
      }
    }

    return KrogerProduct(
      productId: json['productId'] ?? '',
      upc: json['upc'] ?? '',
      description: json['description'] ?? '',
      brand: json['brand'] ?? '',
      size: firstItem?['size'] ?? '',
      price: price?.toDouble(),
      imageUrl: imageUrl,
    );
  }
}