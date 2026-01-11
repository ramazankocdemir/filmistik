import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          username: username,
          role: 'user',
        );

        await _dbRef.child('users').child(user.uid).set(newUser.toMap());

        return null;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
    return "Bir hata oluştu";
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
