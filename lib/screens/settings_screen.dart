import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
      final snapshot = await ref.get();
      if (mounted && snapshot.exists) {
        final data = snapshot.value as Map;
        _nameController.text = data['name'] ?? "";
        _usernameController.text = data['username'] ?? "";
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
        await ref.update({
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
        });

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil başarıyla güncellendi! ✅"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${user.email} adresine şifre sıfırlama bağlantısı gönderildi! 📧",
              ),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Bir hata oluştu.")));
        }
      }
    }
  }

  Future<void> _launchLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Link açılamadı');
      }
    } catch (e) {
      print("Link hatası: $e");
    }
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text(
          "Ayarlar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F111D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profil Bilgileri",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2232),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Ad Soyad", _nameController, Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(
                      "Kullanıcı Adı",
                      _usernameController,
                      Icons.alternate_email,
                    ),
                    const SizedBox(height: 20),

                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                              ),
                              child: const Text(
                                "İptal",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Kaydet",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Bilgileri Düzenle",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Güvenlik",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2232),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.lock_reset,
                  color: Colors.orangeAccent,
                ),
                title: const Text(
                  "Şifremi Sıfırla",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "E-posta adresine sıfırlama linki gönderir.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 14,
                ),
                onTap: _resetPassword,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Bize Ulaşın (Rakosoft)",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2232),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    "E-posta Gönder",
                    "ramazankocdemirr@gmail.com",
                    Icons.mail,
                    "mailto:ramazankocdemirr@gmail.com",
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  _buildContactTile(
                    "LinkedIn",
                    "Rakosoft",
                    Icons.business,
                    "https://www.linkedin.com/company/rakosoft",
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  _buildContactTile(
                    "Instagram",
                    "@rakosoft",
                    Icons.camera_alt,
                    "https://www.instagram.com/rakosoft",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Uygulama Hakkında",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2232),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  "Filmistik v1.0.0",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "Geliştirici: Rakosoft",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Filmistik",
                    applicationVersion: "1.0.0",
                    applicationLegalese: "© 2025 Rakosoft",
                    children: const [
                      Text(
                        "Filmistik, film önerileri yapabileceğiniz ve keşfedebileceğiniz sosyal bir platformdur.",
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Çıkış Yap",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: TextStyle(color: _isEditing ? Colors.white : Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          icon,
          color: _isEditing ? Colors.blueAccent : Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFF0F111D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? "$label boş olamaz" : null,
    );
  }

  Widget _buildContactTile(
    String title,
    String subtitle,
    IconData icon,
    String url,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 16),
      onTap: () => _launchLink(url),
    );
  }
}
