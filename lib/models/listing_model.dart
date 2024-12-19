import 'package:register/models/user.dart';

class Listing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String measurement;
  final String type;
  final String address;
  final String status;
  final List<String> photos;
  bool isFavorited;
  final User? owner;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.measurement,
    required this.type,
    required this.address,
    required this.status,
    required this.photos,
    this.owner,
    this.isFavorited = false,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    try {
      return Listing(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
        measurement: json['measurement'] ?? '',
        type: json['type'] ?? '',
        address: json['address'] ?? '',
        status: json['status'] ?? 'pending',
        photos: json['photos'] != null 
          ? (json['photos'] as List).map((photo) => 
              photo is Map ? (photo['path'] as String? ?? '') : ''
            ).toList()
          : [],
        isFavorited: json['is_favorited'] ?? false,
        owner: json['user'] != null ? User.fromJson({'user': json['user']}) : null,
      );
    } catch (e) {
      print('Error parsing Listing JSON: $e');
      print('Received JSON: $json');
      rethrow;
    }
  }
}