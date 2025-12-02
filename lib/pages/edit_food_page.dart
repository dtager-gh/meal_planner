import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Screen to edit meats, vegetables, and salads
class EditFoodPage extends StatefulWidget {
  const EditFoodPage({super.key});

  @override
  State<EditFoodPage> createState() => _EditFoodPageState();
}

class _EditFoodPageState extends State<EditFoodPage> {
  // Which category is selected in the dropdown
  String category = 'Meat';

  // Text controller for the input box
  final TextEditingController controller = TextEditingController();

  // Returns the correct Hive box depending on selected category
  Box<String> getBox() {
    switch (category) {
      case 'Meat':
        return Hive.box<String>('meats');
      case 'Vegetable':
        return Hive.box<String>('veggies');
      case 'Salad':
        return Hive.box<String>('salads');
      default:
        return Hive.box<String>('meats');
    }
  }

  // Add a new item to the Hive box
  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) return; // Don't add empty text

    final box = getBox();
    box.add(text); // Add new item to Hive
    controller.clear(); // Clear input field

    // Show message at bottom of screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text added to $category list.')),
    );
  }

  // Edit an existing item
  void editItem(Box box, int index, String currentValue) {
    // Pre-fill the edit box with old value
    final editController = TextEditingController(text: currentValue);

    // Show pop-up to edit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          // Cancel button closes dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // Save button updates the Hive item
          ElevatedButton(
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                box.putAt(index, newText); // Overwrite value
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // Remove an item from the list
  void deleteItem(Box box, int index) {
    box.deleteAt(index);
  }


  @override
  Widget build(BuildContext context) {
    // Get the appropriate box based on dropdown selection
    final box = getBox();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Food Items")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            // Dropdown for selecting category
            DropdownButton<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: 'Meat', child: Text('Meat')),
                DropdownMenuItem(value: 'Vegetable', child: Text('Vegetable')),
                DropdownMenuItem(value: 'Salad', child: Text('Salad')),
              ],
              onChanged: (value) {
                setState(() => category = value!);
              },
            ),

            // Input for adding new food item
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter food name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Add button
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add"),
            ),


            const SizedBox(height: 20),
            const Divider(),


            // Title above the list
            Text(
              "$category List",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // List of items (auto-updates because of ValueListenableBuilder)
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<String> b, _) {
                  return ListView.builder(
                    itemCount: b.length,
                    itemBuilder: (context, index) {
                      final item = b.getAt(index) ?? '';

                      return ListTile(
                        title: Text(item),

                        // Edit + Delete buttons
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // Edit button
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editItem(b, index, item),
                            ),

                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteItem(b, index),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}