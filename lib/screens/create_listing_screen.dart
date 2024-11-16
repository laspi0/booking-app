// lib/screens/create_listing_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/listing_service.dart';

class CreateListingScreen extends StatefulWidget {
  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  final ImagePicker _picker = ImagePicker();

  String title = '';
  String description = '';
  double price = 0;
  String measurement = '';
  String type = 'apartment';
  String address = '';
  List<XFile> photos = [];
  bool isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile>? selectedPhotos = await _picker.pickMultiImage();
    if (selectedPhotos != null) {
      setState(() {
        photos.addAll(selectedPhotos);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && photos.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final listing = await _listingService.createListing(
          title: title,
          description: description,
          price: price,
          measurement: measurement,
          type: type,
          address: address,
          photos: photos,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Annonce "${listing.title}" créée avec succès')),
        );
        Navigator.of(context)
            .pop(listing); // Retourne le listing à l'écran précédent
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de l\'annonce')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une annonce'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                onChanged: (value) => title = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                onChanged: (value) => description = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                onChanged: (value) => price = double.tryParse(value) ?? 0,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Surface'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                onChanged: (value) => measurement = value,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: 'Type de bien'),
                items: ['room', 'studio', 'apartment', 'villa']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => type = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                onChanged: (value) => address = value,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Ajouter des photos'),
              ),
              SizedBox(height: 8),
              if (photos.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Image.file(
                          File(photos[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text('Créer l\'annonce'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
