import 'package:flutter/material.dart';

import '../../../models/user.dart';

class MessagesTab extends StatelessWidget {
 final User user;
  
  const MessagesTab({super.key, required this.user});
  final List<Map<String, String>> users = const [
    {"name": "Moussa Diallo", "property": "Appartement à Médina"},
    {"name": "Fatou Ndiaye", "property": "Villa à Almadies"}, 
    {"name": "Abdoulaye Sow", "property": "Studio à Sacré-Coeur"},
    {"name": "Aïda Sarr", "property": "Appartement à Ouakam"},
    {"name": "Mamadou Kane", "property": "Villa à Point E"},
    {"name": "Aminata Fall", "property": "Appartement à Mermoz"},
    {"name": "Ibrahima Diop", "property": "Studio à Yoff"},
    {"name": "Sokhna Mbaye", "property": "Appartement à Fann"},
    {"name": "Cheikh Gueye", "property": "Villa à Ngor"},
    {"name": "Mariama Ba", "property": "Studio à Liberté 6"},
    {"name": "Omar Cissé", "property": "Appartement à Grand Dakar"},
    {"name": "Rama Seck", "property": "Villa à Mamelles"},
    {"name": "Modou Faye", "property": "Studio à HLM"},
    {"name": "Khady Diouf", "property": "Appartement à Plateau"},
    {"name": "Pape Ly", "property": "Villa à Amitié"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          bool isNewMessage = index < 3;
          bool isPremium = index == 4 || index == 8;
          int unreadCount = index == 0 ? 3 : (index == 1 ? 2 : 1);
          
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${index + 50}/200',
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      users[index]["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified, color: Colors.amber, size: 14),
                          SizedBox(width: 2),
                          Text(
                            'VÉRIFIÉ',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                users[index]["property"]!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    index < 3 ? 'Aujourd\'hui' : 'Hier',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  if (isNewMessage)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Navigation vers la conversation
              },
            ),
          );
        },
      ),
    );
  }
}