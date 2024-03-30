import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  var box = await Hive.openBox("Shopping");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _quantitycontroller = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _shopping.keys.map((key) {
      // print("key: $key");
      final item = _shopping.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print("Items length: ${_items.length}");
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shopping.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _shopping.put(itemkey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _shopping.delete(itemkey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An Item has Been Deleted")));
  }

  final _shopping = Hive.box('Shopping');
  void _showform(BuildContext ctx, int? itemkey) async {
    if (itemkey != null) {
      final existitem =
          _items.firstWhere((element) => element['key'] == itemkey);
      _namecontroller.text = existitem["name"];
      _quantitycontroller.text = existitem["quantity"];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              height: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.zero),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                children: [
                  TextField(
                    controller: _namecontroller,
                    decoration: const InputDecoration(hintText: "Name"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _quantitycontroller,
                    decoration: const InputDecoration(hintText: "Quantity"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemkey == null) {
                          _createItem({
                            "name": _namecontroller.text,
                            "quantity": _quantitycontroller.text
                          });
                        }

                        if (itemkey != null) {
                          _updateItem(itemkey, {
                            "name": _namecontroller.text.trim(),
                            "quantity": _quantitycontroller.text.trim()
                          });
                        }
                        _namecontroller.text = '';
                        _quantitycontroller.text = '';
                        Navigator.pop(ctx);
                      },
                      child: Text(itemkey != null ? "Update" : "Create New")),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _items.length,
        itemBuilder: (_, index) {
          final currentItem = _items[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(10),
            color: Colors.orange.shade100,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['quantity'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => _showform(context, currentItem['key']),
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () => _deleteItem(currentItem["key"]),
                      icon: const Icon(Icons.delete)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showform(context, null),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
