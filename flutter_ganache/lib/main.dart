import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ganache/model/item_entity.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace DApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MarketplacePage(),
    );
  }
}

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/items'));
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        setState(() {
          items = itemsJson.map((item) => Item.fromJson(item)).toList();
        });
      } else {
        // Handle error
        print('Failed to load items');
      }
    } catch (e, s) {
      print('Failed to load items: $e, $s');
    }
  }

  Future<void> _listNewItem() async {
    String name = '';
    String description = '';
    String price = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('List New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Price (in wei)'),
              onChanged: (value) => price = value,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('List'),
            onPressed: () async {
              Navigator.of(context).pop();
              final response = await http.post(
                Uri.parse('http://localhost:8080/items'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'name': name,
                  'description': description,
                  'price': price,
                }),
              );
              if (response.statusCode == 200) {
                await _loadItems();
              } else {
                // Handle error
                print('Failed to list item');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace DApp'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.description}\nPrice: ${item.price} wei'),
            trailing: item.sold
                ? Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
                    child: Text('Buy'),
                    onPressed: () async {
                      final response = await http.post(
                        Uri.parse('http://localhost:8080/purchase/${item.itemId}'),
                      );
                      if (response.statusCode == 200) {
                        await _loadItems();
                      } else {
                        // Handle error
                        print('Failed to purchase item');
                      }
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _listNewItem,
      ),
    );
  }
}
