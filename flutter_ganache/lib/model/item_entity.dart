import 'package:flutter_ganache/model/review_entity.dart';

class Item {
  final int itemId;
  final String seller;
  final String name;
  final String description;
  final int price;
  final bool sold;

  Item({
    required this.itemId,
    required this.seller,
    required this.name,
    required this.description,
    required this.price,
    required this.sold,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'],
      seller: json['seller'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      sold: json['sold'],
    );
  }
}
