import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/listing_model.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class ListingService {
  final Dio _dio = Dio();

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
      
      // Adding text fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        MapEntry('measurement', measurement),
        MapEntry('type', type),
        MapEntry('address', address),
      ]);

      // Adding photos
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

      String? token = await TokenService.getToken();
      print('Token: $token');

      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      print('Sending data to API: $formData');

      final response = await _dio.post(
        '${AppConfig.baseUrl}/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('Response from API: ${response.data}');

      return Listing.fromJson(response.data['listing']);
    } on DioException catch (e) {
      if (e.response != null) {
        print('API call failed with response: ${e.response?.data}');
      } else {
        print('API call failed without response: $e');
      }
      throw Exception('Failed to create listing: $e');
    }
  }
}
