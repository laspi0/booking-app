import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../models/user.dart';

class ProfileTab extends StatelessWidget {
   final User user;
  
  const ProfileTab({super.key, required this.user});

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? trailing,
    bool showDivider = true,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: textColor ?? AppTheme.primaryColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
          trailing: trailing != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 25,
            endIndent: 25,
            color: Colors.grey[200],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8),
                                AppTheme.primaryColor.withOpacity(0.5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Agent Immobilier',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('Annonces', '23'),
                          Container(
                            width: 1,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey[300]!,
                                  Colors.grey[300]!.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          _buildStat('Ventes', '12'),
                          Container(
                            width: 1,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey[300]!,
                                  Colors.grey[300]!.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          _buildStat('Avis', '4.8'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    _buildListItem(
                      icon: Icons.person_outline,
                      title: 'Informations personnelles',
                      onTap: () {},
                    ),
                    _buildListItem(
                      icon: Icons.home_outlined,
                      title: 'Mes annonces',
                      trailing: '23',
                      onTap: () {},
                    ),
                    _buildListItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: '3',
                      onTap: () {},
                    ),
                    _buildListItem(
                      icon: Icons.security,
                      title: 'Sécurité',
                      onTap: () {},
                    ),
                    _buildListItem(
                      icon: Icons.help_outline,
                      title: 'Aide et support',
                      onTap: () {},
                    ),
                    _buildListItem(
                      icon: Icons.logout,
                      title: 'Déconnexion',
                      showDivider: false,
                      textColor: Colors.red[400],
                      onTap: () {
                        // Logique de déconnexion
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}