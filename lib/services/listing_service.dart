// lib/services/listing_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/listing_model.dart';

class ListingService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://192.168.1.11:8000/api/listings';

  Future<Listing> createListing({
    required String title,
    required String description,
    required double price,
    required String measurement,
    required String type,
    required String address,
    required List<XFile> photos,
  }) async {
    try {
      FormData formData = FormData();
      
      // Ajout des champs texte
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        MapEntry('measurement', measurement),
        MapEntry('type', type),
        MapEntry('address', address),
      ]);

      // Ajout des photos
      for (var photo in photos) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.name,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '$baseUrl/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_TOKEN_HERE',
            'Accept': 'application/json',
          },
        ),
      );

      return Listing.fromJson(response.data['listing']);
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }
}