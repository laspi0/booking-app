import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/listing_service.dart';
import '../models/listing_model.dart';

class AddListingScreen extends StatefulWidget {
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listingService = ListingService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _measurementController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<XFile> _photos = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _measurementController.dispose();
    _typeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _photos = pickedFiles;
      });
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate() || _photos.isEmpty) return;

    try {
      Listing listing = await _listingService.createListing(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        measurement: _measurementController.text,
        type: _typeController.text,
        address: _addressController.text,
        photos: _photos,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Listing created: ${listing.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create listing: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Listing'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
                ),
                TextFormField(
                  controller: _measurementController,
                  decoration: InputDecoration(labelText: 'Measurement'),
                  validator: (value) => value!.isEmpty ? 'Please enter a measurement' : null,
                ),
                TextFormField(
                  controller: _typeController,
                  decoration: InputDecoration(labelText: 'Type'),
                  validator: (value) => value!.isEmpty ? 'Please enter a type' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickPhotos,
                  child: Text('Pick Photos'),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _photos.map((photo) {
                    return Image.file(
                      File(photo.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitListing,
                  child: Text('Create Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
