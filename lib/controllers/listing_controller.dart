import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:register/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/listing_model.dart';


class ListingController {
  final BuildContext context;
  final TextEditingController commentController;

  ListingController(this.context, this.commentController);

  Future<void> postComment(Listing listing, User user) async {
    if (commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le commentaire ne peut pas être vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/listings/${listing.id}/comments'),
      headers: {
        'Authorization': 'Bearer ${user.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': commentController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commentaire ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'ajout du commentaire'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de téléphone non disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel téléphonique'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
