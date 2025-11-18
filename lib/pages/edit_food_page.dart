import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class EditFoodPage extends StatefulWidget {
  const EditFoodPage({super.key});


  @override
  State<EditFoodPage> createState() => _EditFoodPageState();
}


class _EditFoodPageState extends State<EditFoodPage> {
  String category = 'Meat';
  final TextEditingController controller = TextEditingController();


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

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) return;


    final box = getBox();
    box.add(text);
    controller.clear();


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text added to $category list.')),
    );
  }

  void editItem(Box box, int index, String currentValue) {
    final editController = TextEditingController(text: currentValue);


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                box.putAt(index, newText);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void deleteItem(Box box, int index) {
    box.deleteAt(index);
  }


  @override
  Widget build(BuildContext context) {
    final box = getBox();


    return Scaffold(
      appBar: AppBar(title: const Text("Manage Food Items")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter food name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add"),
            ),


            const SizedBox(height: 20),
            const Divider(),
            Text(
              "$category List",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),


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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editItem(b, index, item),
                            ),
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