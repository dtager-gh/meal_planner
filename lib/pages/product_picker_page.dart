import 'package:flutter/material.dart';
import '../services/kroger_api_service.dart';

class ProductPickerPage extends StatefulWidget {
  final KrogerApiService krogerService;
  final String ingredient;
  final String locationId;

  const ProductPickerPage({
    super.key,
    required this.krogerService,
    required this.ingredient,
    required this.locationId,
  });

  @override
  State<ProductPickerPage> createState() => _ProductPickerPageState();
}

class _ProductPickerPageState extends State<ProductPickerPage> {
  bool _loading = true;
  String? _error;
  List<KrogerProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await widget.krogerService.searchProducts(
        searchTerm: widget.ingredient,
        locationId: widget.locationId,
        limit: 20,
      );
      setState(() => _products = results);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose: ${widget.ingredient}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, i) {
          final p = _products[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: (p.imageUrl != null)
                  ? Image.network(
                p.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported),
              )
                  : const Icon(Icons.shopping_basket),
              title: Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.brand} - ${p.size}', style: const TextStyle(fontSize: 12)),
                  if (p.price != null)
                    Text('\$${p.price!.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Return selected product to caller
                Navigator.pop(context, p);
              },
            ),
          );
        },
      ),
    );
  }
}