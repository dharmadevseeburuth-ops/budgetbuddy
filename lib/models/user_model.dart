class UserModel {
  final int? id;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}