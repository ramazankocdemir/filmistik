import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  void _register() async {
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    if (password != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Şifreler eşleşmiyor")));
      return;
    }

    String? result = await _authService.signUp(
      email: email,
      password: password,
      username: username,
      name: name,
    );

    if (result == null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseDatabase.instance.ref().child('users').child(uid).set({
          'uid': uid,
          'name': name,
          'username': username,
          'email': email,
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print("Veritabanı kayıt hatası: $e");
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      // Hata var
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $result")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text(
          "Yeni Hesap Oluştur",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F111D),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildTextField(_nameController, "Ad Soyad", Icons.person),
              const SizedBox(height: 16),
              _buildTextField(
                _usernameController,
                "Kullanıcı Adı",
                Icons.alternate_email,
              ),
              const SizedBox(height: 16),
              _buildTextField(_emailController, "E-posta", Icons.email),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                "Şifre",
                Icons.lock,
                isObscure: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _confirmPasswordController,
                "Şifre Tekrar",
                Icons.lock_outline,
                isObscure: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1F2232),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
