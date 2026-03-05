import 'package:flutter/material.dart';
import '../services/user_food_service.dart';

class EditFoodPage extends StatefulWidget {
  const EditFoodPage({super.key});

  @override
  State<EditFoodPage> createState() => _EditFoodPageState();
}

class _EditFoodPageState extends State<EditFoodPage> {
  String category = 'Meat';
  final TextEditingController controller = TextEditingController();

  final UserFoodService foodService = UserFoodService();

  bool loading = true;
  bool saving = false;
  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() => loading = true);
    try {
      foods = await foodService.getFoods(category);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load foods: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addItem() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => saving = true);
    try {
      await foodService.addFood(category, text);
      controller.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text added to $category list.')),
        );
      }

      await _loadFoods();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _editItem(String id, String currentValue) async {
    final editController = TextEditingController(text: currentValue);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != currentValue) {
                Navigator.pop(context);
                setState(() => saving = true);
                try {
                  await foodService.updateFoodName(id, newText);
                  await _loadFoods();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => saving = false);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    setState(() => saving = true);
    try {
      await foodService.deleteFood(id);
      await _loadFoods();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _toggleEnabled(String id, bool enabled) async {
    // Optimistic UI (feels instant)
    final idx = foods.indexWhere((f) => f['id'] == id);
    if (idx != -1) {
      setState(() {
        foods[idx]['enabled'] = enabled;
      });
    }

    try {
      await foodService.setEnabled(id, enabled);
    } catch (e) {
      // rollback
      if (idx != -1) {
        setState(() {
          foods[idx]['enabled'] = !enabled;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Food Items"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              DropdownButton<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'Meat', child: Text('Meat')),
                  DropdownMenuItem(value: 'Vegetable', child: Text('Vegetable')),
                  DropdownMenuItem(value: 'Salad', child: Text('Salad')),
                ],
                onChanged: saving
                    ? null
                    : (value) async {
                  if (value == null) return;
                  setState(() => category = value);
                  await _loadFoods();
                },
              ),
              TextField(
                controller: controller,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Enter food name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addItem(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: saving ? null : _addItem,
                child: saving ? const Text("Working...") : const Text("Add"),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Text(
                "$category List",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : foods.isEmpty
                    ? const Center(child: Text("No items yet. Add some above."))
                    : ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final item = foods[index];
                    final id = item['id'] as String;
                    final name = (item['name'] ?? '') as String;
                    final enabled = (item['enabled'] ?? true) as bool;

                    return ListTile(
                      leading: Switch(
                        value: enabled,
                        onChanged: saving
                            ? null
                            : (v) => _toggleEnabled(id, v),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          decoration: enabled
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: enabled
                          ? const Text("Included in random selection")
                          : const Text("Excluded from random selection"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: saving ? null : () => _editItem(id, name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: saving ? null : () => _deleteItem(id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}