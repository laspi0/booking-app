import 'package:flutter/material.dart';
import 'package:register/models/user.dart';
import 'package:register/config/theme.dart';
import 'package:register/services/conversation_service.dart';
import 'package:register/models/conversation.dart';
import 'package:register/screens/chat_screen.dart';

class OwnerInfoWidget extends StatelessWidget {
  final User owner;
  final Function(String) onPhoneCall;
  final int currentUserId;
  final int listingId;

  const OwnerInfoWidget({
    Key? key,
    required this.owner,
    required this.onPhoneCall,
    required this.currentUserId,
    required this.listingId,
  }) : super(key: key);

  Future<void> _handleMessagePress(BuildContext context) async {
    try {
      // Afficher l'indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        },
      );

      // Vérifier si une conversation existe déjà
      Conversation? conversation = await ConversationService.getConversationByUsers(
        currentUserId,
        owner.id,
      );

      // Si aucune conversation n'existe, en créer une nouvelle
      if (conversation == null) {
        conversation = await ConversationService.startConversation(
          userId: owner.id,
          listingId: listingId,
        );
      }

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.pop(context);

        // Naviguer vers l'écran de chat
        if (conversation != null) {
          print('Navigating to chat screen with conversation ID: ${conversation.id}');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversation: conversation!),
            ),
          );
        } else {
          print('Conversation is null after creation');
          throw Exception('La conversation est null après la tentative de création');
        }
      }
    } catch (e) {
      // Gérer les erreurs
      if (context.mounted) {
        Navigator.pop(context); // Fermer l'indicateur de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar du propriétaire
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),

          // Informations du propriétaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Vendeur Pro',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Boutons d'action
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Bouton Message
                IconButton(
                  icon: const Icon(
                    Icons.message_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => _handleMessagePress(context),
                  tooltip: 'Message',
                ),
                
                // Séparateur
                Container(
                  width: 1,
                  height: 24,
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                
                // Bouton Téléphone
                IconButton(
                  icon: const Icon(
                    Icons.phone_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => owner.number != null 
                    ? onPhoneCall(owner.number!) 
                    : null,
                  tooltip: 'Appeler',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
