import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/movie_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _showApproved = false;

  Future<void> _approveMovie(MovieModel movie) async {
    final ref = FirebaseDatabase.instance.ref('movies/${movie.id}');
    await ref.update({'status': 'approved'});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${movie.title} yayına alındı! 🚀"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteMovie(String movieId) async {
    await FirebaseDatabase.instance.ref('movies/$movieId').remove();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _showApproved ? "Film silindi 🗑️" : "Film reddedildi 🗑️",
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  List<String> _parseTags(String input) {
    final raw = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final cleaned = <String>[];

    for (final t in raw) {
      final key = t.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        cleaned.add(t);
      }
    }

    if (cleaned.length > 5) return cleaned.take(5).toList();
    return cleaned;
  }

  void _editMovie(MovieModel movie) {
    final TextEditingController plotController = TextEditingController(
      text: movie.plot,
    );

    final TextEditingController tagsController = TextEditingController(
      text: movie.keywords.join(', '),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2232),
          title: const Text(
            "Filmi Düzenle",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Özet (OMDb)", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: plotController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Anahtar Kelimeler (max 5, virgülle)",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: tagsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(hint: "uzay, savaş, aksiyon"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final tags = _parseTags(tagsController.text);

                if (tags.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("En az 1 anahtar kelime girmen lazım."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                await FirebaseDatabase.instance
                    .ref('movies/${movie.id}')
                    .update({
                      'plot': plotController.text.trim(),
                      'keywords': tags,
                    });

                if (!mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Film güncellendi ✏️"),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _showApproved ? "Yayındaki Filmler" : "Onay Bekleyen Filmler";

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F111D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showApproved = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showApproved
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1F2232),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Bekleyenler"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showApproved = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showApproved
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1F2232),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Yayındakiler"),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('movies').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Text(
                      _showApproved
                          ? "Yayında film yok"
                          : "Onay bekleyen film yok",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final List<MovieModel> movies = [];

                data.forEach((key, value) {
                  final movie = MovieModel.fromMap(
                    Map<String, dynamic>.from(value),
                  ).copyWith(id: key);
                  if (_showApproved) {
                    if (movie.status == 'approved') movies.add(movie);
                  } else {
                    if (movie.status == 'pending') movies.add(movie);
                  }
                });

                if (movies.isEmpty) {
                  return Center(
                    child: Text(
                      _showApproved
                          ? "Yayında film yok"
                          : "Onay bekleyen film yok",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return _buildAdminCard(movie);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(MovieModel movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Image.network(
              movie.posterUrl,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 70,
                color: Colors.black26,
                child: const Icon(Icons.movie, color: Colors.white70),
              ),
            ),
            title: Text(
              movie.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              movie.keywords.join(', '),
              style: TextStyle(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editMovie(movie),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Düzenle",
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteMovie(movie.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Reddet", maxLines: 1, softWrap: false),
                    ),
                  ),
                ),

                if (!_showApproved) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveMovie(movie),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Onayla", maxLines: 1, softWrap: false),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF0F111D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
