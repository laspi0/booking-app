import 'package:flutter/material.dart';
import 'package:register/screens/add_page.dart';
import 'package:register/screens/detail_page.dart';
import '../../../config/theme.dart';
import '../../../models/user.dart';

class HomeTab extends StatelessWidget {
  final User user;
  
  const HomeTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Liste des quartiers de Dakar
    final quartiers = [
      'Almadies',
      'Mermoz',
      'Ngor',
      'Ouakam',
      'Plateau',
      'Point E',
      'Sacré-Cœur',
      'Grand Yoff',
      'Liberté 6',
      'Fann'
    ];

    // Liste des prix en FCFA
    final prix = [
      '250.000',
      '175.000',
      '300.000',
      '225.000',
      '350.000',
      '200.000',
      '275.000',
      '150.000',
      '185.000',
      '265.000'
    ];

    // Liste des types
    final types = ['Récent', 'Populaire', 'Meilleures offres'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Rechercher un logement',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...types.map((type) => _buildTab(
                              type,
                              isSelected: type == 'Récent',
                            )),
                        ...quartiers.map((quartier) => _buildTab(quartier)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              title: 'Villa ${quartiers[index]}',
                              price: '${prix[index]} FCFA',
                              location: quartiers[index],
                              description: 'Detailed description about the property...',
                              features: [
                                '${(index + 2) * 25} m²',
                                '${index + 2} chambres',
                                '${index + 1} sdb',
                              ],
                              images: [
                                'https://picsum.photos/seed/${index + 1}/400/250',
                                'https://picsum.photos/seed/${index + 2}/400/250',
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Image.network(
                                      'https://picsum.photos/seed/${index + 1}/400/250',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${prix[index]} FCFA',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Villa ${quartiers[index]}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.favorite_border),
                                            onPressed: () {},
                                            color: AppTheme.primaryColor,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.grey, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            quartiers[index],
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildFeature(Icons.square_foot,
                                              '${(index + 2) * 25} m²'),
                                          const SizedBox(width: 24),
                                          _buildFeature(
                                              Icons.bed, '${index + 2} chambres'),
                                          const SizedBox(width: 24),
                                          _buildFeature(
                                              Icons.bathroom, '${index + 1} sdb'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
