class User {
  final int id;
  final String name;
  final String email;
  final String? number;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.number,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Vérifie si les données sont imbriquées dans un objet 'user' ou directement au premier niveau
    final userData = json.containsKey('user') ? json['user'] : json;
    
    return User(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      number: userData['number'],
      token: json['access_token'], // Garde le token au premier niveau
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'number': number,
    };
  }
}