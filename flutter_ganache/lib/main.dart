import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ganache/model/item_entity.dart';
import 'package:flutter_ganache/model/review_entity.dart';
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
  List<ReviewEntity> reviews = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/items'));
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        setState(() {
          items = itemsJson.map((item) => Item.fromJson(item)).toList();
        });
      } else {
        _showErrorSnackBar('Failed to load items');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addReview(int itemId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReviewDialog(),
    );

    if (result != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/review/$itemId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(result),
        );
        if (response.statusCode == 200) {
          await _loadItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review added successfully')),
          );
        } else {
          _showErrorSnackBar('Failed to add review');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _listNewItem() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => NewItemDialog(),
    );

    if (result != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/items'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(result),
        );
        if (response.statusCode == 200) {
          await _loadItems();
        } else {
          _showErrorSnackBar('Failed to list item');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace DApp'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ItemTile(
                  item: items[index],
                  review: reviews,
                  onPurchase: () => _purchaseItem(items[index].itemId),
                  onReview: () => _addReview(items[index].itemId),
                  loadReview: (itemsId) {
                    _loadReviews(itemsId);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _listNewItem,
      ),
    );
  }

  Future<void> _purchaseItem(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/purchase/$itemId'),
      );
      if (response.statusCode == 200) {
        await _loadItems();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item purchased successfully')),
        );
      } else {
        _showErrorSnackBar('Failed to purchase item');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _loadReviews(int itemId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/reviews/$itemId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = jsonDecode(response.body);
        setState(() {
          reviews = reviewsJson.map((item) => ReviewEntity.fromJson(item)).toList();
        });
      } else {
        _showErrorSnackBar('Failed to load reviews');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }
}

class ReviewDialog extends StatefulWidget {
  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Review'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a rating';
                }
                int? rating = int.tryParse(value);
                if (rating == null || rating < 1 || rating > 5) {
                  return 'Rating must be between 1 and 5';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Comment'),
              validator: (value) => value!.isEmpty ? 'Please enter a comment' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'rating': int.parse(_ratingController.text),
                'comment': _commentController.text,
              });
            }
          },
        ),
      ],
    );
  }
}

class NewItemDialog extends StatefulWidget {
  @override
  _NewItemDialogState createState() => _NewItemDialogState();
}

class _NewItemDialogState extends State<NewItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('List New Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price (in wei)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Please enter a valid price' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('List'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'description': _descriptionController.text,
                'price': _priceController.text,
              });
            }
          },
        ),
      ],
    );
  }
}

class ReviewTile extends StatelessWidget {
  final ReviewEntity review;

  const ReviewTile({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        children: [
          // Starts
          Row(
            children: List.generate(
              review.rating,
              (index) => Icon(Icons.star, color: Colors.orange, size: 16),
            ),
          ),
        ],
      ),
      subtitle: Text('Comment: ${review.comment}'),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Item item;
  final List<ReviewEntity> review;
  final VoidCallback onPurchase;
  final VoidCallback onReview;
  final Function(int itemsId) loadReview;

  const ItemTile({
    Key? key,
    required this.item,
    this.review = const [],
    required this.onPurchase,
    required this.onReview,
    required this.loadReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Colors.black12,
      expandedAlignment: Alignment.topLeft,
      title: Text(item.name),
      subtitle: Text('Price: ${item.price} wei'),
      onExpansionChanged: (value) {
        if (value) {
          // Load reviews
          loadReview(item.itemId);
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${item.description}'),
              SizedBox(height: 8),
              if (item.sold) ...[
                SizedBox(height: 8),
                Text('This is already sold'),
              ] else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Buy',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: onPurchase,
                ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add Review',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: onReview,
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Reviews:'),
                    ),
                    ...review.map(
                      (review) => ReviewTile(
                        review: review,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
