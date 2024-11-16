// lib/models/listing.dart
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
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      measurement: json['measurement'],
      type: json['type'],
      address: json['address'],
      status: json['status'],
      photos: (json['photos'] as List).map((photo) => photo['path'] as String).toList(),
    );
  }
}