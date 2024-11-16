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
    print('User JSON: $json'); // Debugging line
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      number: json['user']['number'],
      token: json['access_token'], // Ensure token is correctly parsed
    );
  }
}
