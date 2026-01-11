class UserModel {
  String uid;
  String email;
  String username;
  String role;
  List<String> savedMovies;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.role = 'user',
    this.savedMovies = const [],
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',
      savedMovies: List<String>.from(map['savedMovies'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'savedMovies': savedMovies,
    };
  }
}
