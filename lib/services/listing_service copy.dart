import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/listing_model.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class ListingService {
  final Dio _dio = Dio()..interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  Future<List<Listing>> getListings() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      print('Calling API: ${AppConfig.baseUrl}/listings');
      final response = await _dio.get(
        '${AppConfig.baseUrl}/listings',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Listing.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print('DioError type: ${e.type}');
      print('DioError message: ${e.message}');
      print('DioError response: ${e.response?.data}');
      throw Exception('Error fetching listings: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Erreur lors de la récupération des annonces.');
    }
  }

  Future<Listing> getListing(int id) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      final response = await _dio.get(
        '${AppConfig.baseUrl}/listings/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }

      return Listing.fromJson(response.data);
    } on DioException catch (e) {
      print('DioError details: ${e.response?.data}');
      throw Exception('Failed to fetch listing: ${e.message}');
    }
  }

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
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

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

      print('Sending request to: ${AppConfig.baseUrl}/listings');
      final response = await _dio.post(
        '${AppConfig.baseUrl}/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }

      return Listing.fromJson(response.data);
    } on DioException catch (e) {
      print('DioError type: ${e.type}');
      print('DioError message: ${e.message}');
      print('DioError response: ${e.response?.data}');
      throw Exception('Failed to create listing: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Failed to create listing: $e');
    }
  }

  Future<Listing> updateListing({
    required int id,
    required String title,
    required String description,
    required double price,
    required String measurement,
    required String type,
    required String address,
    List<XFile>? newPhotos,
    List<String>? photoIdsToDelete,
  }) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      FormData formData = FormData();
      
      // Adding text fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        MapEntry('measurement', measurement),
        MapEntry('type', type),
        MapEntry('address', address),
        MapEntry('_method', 'PUT'), // Laravel form method spoofing
      ]);

      // Adding photo IDs to delete
      if (photoIdsToDelete != null && photoIdsToDelete.isNotEmpty) {
        for (var photoId in photoIdsToDelete) {
          formData.fields.add(MapEntry('photos_to_delete[]', photoId));
        }
      }

      // Adding new photos
      if (newPhotos != null && newPhotos.isNotEmpty) {
        for (var photo in newPhotos) {
          formData.files.add(
            MapEntry(
              'new_photos[]',
              await MultipartFile.fromFile(
                photo.path,
                filename: photo.name,
              ),
            ),
          );
        }
      }

      final response = await _dio.post(
        '${AppConfig.baseUrl}/listings/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }

      return Listing.fromJson(response.data);
    } on DioException catch (e) {
      print('DioError details: ${e.response?.data}');
      throw Exception('Failed to update listing: ${e.message}');
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      final response = await _dio.delete(
        '${AppConfig.baseUrl}/listings/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      print('DioError details: ${e.response?.data}');
      throw Exception('Failed to delete listing: ${e.message}');
    }
  }

  Future<List<Listing>> searchListings({
    String? query,
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      Map<String, dynamic> queryParameters = {};
      if (query != null && query.isNotEmpty) queryParameters['q'] = query;
      if (type != null && type.isNotEmpty) queryParameters['type'] = type;
      if (minPrice != null) queryParameters['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParameters['max_price'] = maxPrice.toString();

      final response = await _dio.get(
        '${AppConfig.baseUrl}/listings/search',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
      }

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Listing.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print('DioError details: ${e.response?.data}');
      throw Exception('Failed to search listings: ${e.message}');
    }
  }
}