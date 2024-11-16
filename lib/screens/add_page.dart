import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/listing_service.dart';
import '../models/listing_model.dart';
import '../config/theme.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

String _getTypeLabel(String type) {
  switch (type) {
    case 'room':
      return 'Chambre';
    case 'studio':
      return 'Studio';
    case 'apartment':
      return 'Appartement';
    case 'villa':
      return 'Villa';
    default:
      return type;
  }
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _listingService = ListingService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _measurementController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  String? _selectedType;
  List<XFile> _photos = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _measurementController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une photo')),
      );
      return;
    }

    try {
      Listing listing = await _listingService.createListing(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        measurement: _measurementController.text,
        type: _selectedType ?? 'apartment',
        address: _addressController.text,
        photos: _photos,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce créée : ${listing.title}')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création : $e')),
      );
    }
  }

  Widget _buildPhotoSection() {
    if (_photos.isEmpty) {
      return GestureDetector(
        onTap: _pickPhotos,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Ajouter des photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Format JPG, PNG (Max. 5 Mo)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _photos.map((photo) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(photo.path),
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _photos.remove(photo);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickPhotos,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Ajouter plus de photos'),
          ),
        ],
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 22,
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) => value?.isEmpty == true ? 'Ce champ est requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Nouvelle annonce',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhotoSection(),
                      const SizedBox(height: 25),
                      const Text(
                        'Informations principales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _titleController,
                        'Titre de l\'annonce',
                        Icons.edit,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _priceController,
                              'Prix',
                              Icons.euro,
                              suffix: '€',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              _measurementController,
                              'Surface',
                              Icons.square_foot,
                              suffix: 'm²',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
  value: _selectedType,
  decoration: const InputDecoration(
    hintText: 'Type de bien',
    prefixIcon: Icon(
      Icons.home,
      color: AppTheme.primaryColor,
      size: 22,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.all(20),
  ),
  items: ['room', 'studio', 'apartment', 'villa']  // Utiliser les valeurs en anglais
      .map((String type) {
    return DropdownMenuItem<String>(
      value: type,
      child: Text(_getTypeLabel(type)),  // Fonction pour afficher le label en français
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedType = value;
    });
  },
  validator: (value) =>
      value == null ? 'Veuillez sélectionner un type' : null,
),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _bedroomsController,
                              'Chambres',
                              Icons.bed,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              _bathroomsController,
                              'Salles de bain',
                              Icons.bathroom,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Localisation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _addressController,
                        'Adresse complète',
                        Icons.location_on,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Description détaillée du bien...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                          validator: (value) =>
                              value?.isEmpty == true ? 'Ce champ est requis' : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _submitListing,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Publier l\'annonce',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}