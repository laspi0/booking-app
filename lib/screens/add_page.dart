import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/listing_service.dart';
import '../models/listing_model.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _listingService = ListingService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _measurementController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedType;
  List<XFile> _photos = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _measurementController.dispose();
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
      print('Photos picked: ${_photos.map((photo) => photo.path).join(', ')}');
    } else {
      print('No photos selected');
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate() || _selectedType == null) {
      print('Form validation failed');
      return;
    }

    if (_photos.isEmpty) {
      print('No photos selected');
      return;
    }

    print('Form validated, proceeding with submission');
    print('Title: ${_titleController.text}');
    print('Description: ${_descriptionController.text}');
    print('Price: ${_priceController.text}');
    print('Measurement: ${_measurementController.text}');
    print('Type: $_selectedType');
    print('Address: ${_addressController.text}');
    print('Photos count: ${_photos.length}');

    try {
      Listing listing = await _listingService.createListing(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        measurement: _measurementController.text,
        type: _selectedType!,
        address: _addressController.text,
        photos: _photos,
      );

      print('Listing created: ${listing.title}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Listing created: ${listing.title}')),
      );
    } catch (e) {
      print('Failed to create listing: $e');
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
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(labelText: 'Type'),
                  items: ['room', 'studio', 'apartment', 'villa'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a type' : null,
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
