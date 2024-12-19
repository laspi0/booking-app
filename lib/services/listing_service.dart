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
      // Validation des données
      if (title.isEmpty) throw Exception('Le titre ne peut pas être vide');
      if (description.isEmpty) throw Exception('La description ne peut pas être vide');
      if (price <= 0) throw Exception('Le prix doit être supérieur à 0');
      if (measurement.isEmpty) throw Exception('La surface ne peut pas être vide');
      if (photos.isEmpty) throw Exception('Au moins une photo est requise');

      // Vérification du token
      String? token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Vous devez être connecté pour créer une annonce');
      }

      // Préparation des fichiers photos
      List<MapEntry<String, MultipartFile>> photoFiles = [];
      try {
        for (var photo in photos) {
          if (await photo.length() > 5 * 1024 * 1024) { // 5 MB limit
            throw Exception('La photo ${photo.name} dépasse la limite de 5 Mo');
          }
          
          photoFiles.add(
            MapEntry(
              'photos[]',
              await MultipartFile.fromFile(
                photo.path,
                filename: photo.name,
              ),
            ),
          );
        }
      } catch (e) {
        throw Exception('Erreur lors du traitement des photos: $e');
      }

      // Création du FormData
      FormData formData = FormData();
      
      // Ajout des champs texte
      Map<String, dynamic> fields = {
        'title': title.trim(),
        'description': description.trim(),
        'price': price.toString(),
        'measurement': measurement.trim(),
        'type': type.trim(),
        'address': address.trim(),
        'status': 'pending', // Statut par défaut
      };

      // Ajout des champs au FormData
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Ajout des photos au FormData
      formData.files.addAll(photoFiles);

      print('📤 Envoi de la requête à: ${AppConfig.baseUrl}/listings');
      print('📋 Données envoyées: $fields');
      print('📸 Nombre de photos: ${photos.length}');

      // Envoi de la requête
      final response = await _dio.post(
        '${AppConfig.baseUrl}/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('📥 Statut de la réponse: ${response.statusCode}');
      print('📄 Données reçues: ${response.data}');

      // Gestion des erreurs de réponse
      if (response.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }

      if (response.statusCode == 413) {
        throw Exception('Les fichiers sont trop volumineux');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        String errorMessage = response.data is Map 
            ? response.data['message'] ?? 'Erreur inconnue'
            : 'Erreur inconnue';
        throw Exception('Erreur serveur ${response.statusCode}: $errorMessage');
      }

      if (response.data == null) {
        throw Exception('Aucune donnée reçue du serveur');
      }

      try {
        final listing = Listing.fromJson(response.data);
        print('✅ Annonce créée avec succès. ID: ${listing.id}');
        return listing;
      } catch (e) {
        print('❌ Erreur lors de la conversion des données: $e');
        print('Structure des données reçues: ${response.data.runtimeType}');
        print('Données reçues: ${response.data}');
        throw Exception('Erreur lors de la création de l\'annonce: format de données incorrect');
      }

    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.type}');
      print('Message: ${e.message}');
      print('Réponse: ${e.response?.data}');
      
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Délai d\'attente dépassé, veuillez réessayer';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Erreur de connexion, vérifiez votre connexion internet';
          break;
        default:
          errorMessage = e.response?.data?['message'] ?? 
                        'Erreur lors de la création de l\'annonce';
      }
      throw Exception(errorMessage);
      
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur lors de la création de l\'annonce: $e');
    }
  }

  getUserData() {}
}
