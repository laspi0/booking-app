import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/listing_model.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class ListingService {
  final Dio _dio = Dio()
    ..interceptors.add(LogInterceptor(
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
        throw Exception(
            'Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
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
        throw Exception(
            'Server returned ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}');
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
      // Validation locale alignée avec Laravel
      _validateInputData(
        title: title,
        description: description,
        price: price,
        measurement: measurement,
        type: type,
        photos: photos,
      );

      // Récupération et vérification du token
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Vous devez être connecté pour créer une annonce');
      }

      // Validation et traitement des photos
      final photoFiles = await _processPhotos(photos);

      // Création du FormData avec la structure exacte attendue par Laravel
      final formData = FormData();

      // Ajout des champs texte avec les noms exacts attendus par Laravel
      formData.fields.addAll([
        MapEntry('title', title.trim()),
        MapEntry('description', description.trim()),
        MapEntry('price', price.toString()),
        MapEntry('measurement', measurement.trim()),
        MapEntry('type', type.trim()),
        MapEntry('address', address.trim()),
      ]);

      // Ajout des photos avec le nom de champ attendu par Laravel
      for (var photoFile in photoFiles) {
        formData.files.add(MapEntry('photos[]', photoFile));
      }

      print('📤 Envoi de la requête à: ${AppConfig.baseUrl}/listings');
      print('📋 Données envoyées:');
      formData.fields
          .forEach((field) => print('- ${field.key}: ${field.value}'));
      print('📸 Nombre de photos: ${photos.length}');

      final response = await _dio.post(
        '${AppConfig.baseUrl}/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Statut de la réponse: ${response.statusCode}');
      print('📄 Données reçues: ${response.data}');

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _validateInputData({
    required String title,
    required String description,
    required double price,
    required String measurement,
    required String type,
    required List<XFile> photos,
  }) {
    if (title.trim().isEmpty || title.length > 255) {
      throw Exception(
          'Le titre est requis et ne doit pas dépasser 255 caractères');
    }
    if (description.trim().isEmpty) {
      throw Exception('La description est requise');
    }
    if (price <= 0) {
      throw Exception('Le prix doit être supérieur à 0');
    }
    if (measurement.trim().isEmpty) {
      throw Exception('La surface est requise');
    }
    if (!['room', 'studio', 'apartment', 'villa'].contains(type)) {
      throw Exception('Le type doit être : room, studio, apartment ou villa');
    }
    if (photos.isEmpty || photos.length > 10) {
      throw Exception('Entre 1 et 10 photos sont requises');
    }
  }

  Future<List<MultipartFile>> _processPhotos(List<XFile> photos) async {
    List<MultipartFile> photoFiles = [];

    for (var photo in photos) {
      // Vérifie la taille (2MB = 2 * 1024 * 1024 bytes)
      if (await photo.length() > 2 * 1024 * 1024) {
        throw Exception('La photo ${photo.name} dépasse la limite de 2 Mo');
      }
      // Vérifie l'extension
      final extension = photo.name.split('.').last.toLowerCase();
      if (!['jpeg', 'jpg', 'png', 'gif'].contains(extension)) {
        throw Exception(
            'Le format de la photo ${photo.name} n\'est pas supporté. Formats acceptés : JPEG, PNG, GIF');
      }

      try {
        final file = await MultipartFile.fromFile(
          photo.path,
          filename: photo.name,
        );
        photoFiles.add(file);
      } catch (e) {
        throw Exception(
            'Erreur lors du traitement de la photo ${photo.name}: $e');
      }
    }

    return photoFiles;
  }

  Listing _handleResponse(Response response) {
    if (response.statusCode == 422) {
      final errors = response.data['errors'] as Map<String, dynamic>? ?? {};
      throw Exception(_formatValidationErrors(errors));
    }

    if (response.statusCode == 201) {
      try {
        return Listing.fromJson(response.data['listing']);
      } catch (e) {
        print('❌ Erreur de conversion des données: $e');
        throw Exception(
            'Erreur lors de la création de l\'annonce: format de données incorrect');
      }
    }

    throw Exception(
        'Erreur lors de la création de l\'annonce: ${response.statusCode}');
  }

  String _formatValidationErrors(Map<String, dynamic> errors) {
    if (errors.isEmpty) return 'Erreur de validation';

    return errors.entries.map((entry) {
      final messages = entry.value is List
          ? (entry.value as List).join(', ')
          : entry.value.toString();
      return '${entry.key}: $messages';
    }).join('\n');
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      print('❌ Erreur Dio: ${e.type}');
      print('Message: ${e.message}');
      print('Réponse: ${e.response?.data}');
    } else {
      print('❌ Erreur inattendue: $e');
    }
  }

  getUserData() {}
}
