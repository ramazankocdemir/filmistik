import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/movie_model.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _actorController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedGenre = "Bilim Kurgu";
  String _posterUrl = "";
  String _fetchedRating = "N/A";
  bool _isLoading = false;
  bool _isSearching = false;

  final List<String> _genres = [
    "Bilim Kurgu",
    "Aksiyon",
    "Dram",
    "Korku",
    "Komedi",
    "Fantastik",
    "Romantik",
  ];

  String _mapOmdbGenreToTurkish(String omdbGenre) {
    final g = omdbGenre.toLowerCase();

    if (g.contains('sci-fi') || g.contains('science fiction')) {
      return 'Bilim Kurgu';
    }
    if (g.contains('action') || g.contains('adventure')) {
      return 'Aksiyon';
    }
    if (g.contains('horror')) {
      return 'Korku';
    }
    if (g.contains('comedy')) {
      return 'Komedi';
    }
    if (g.contains('romance')) {
      return 'Romantik';
    }
    if (g.contains('fantasy')) {
      return 'Fantastik';
    }
    if (g.contains('drama')) {
      return 'Dram';
    }

    return 'Dram';
  }

  Future<void> _searchMovieFromApi() async {
    final String movieName = _titleController.text.trim();

    if (movieName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir film adı yazın!")),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _posterUrl = "";
      _fetchedRating = "N/A";
      _actorController.clear();
    });

    try {
      final Uri url = Uri.https('www.omdbapi.com', '/', {
        't': movieName,
        'apikey': '3db90da3',
      });

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['Response'] == "True") {
        setState(() {
          _posterUrl = (data['Poster'] != null && data['Poster'] != "N/A")
              ? data['Poster']
              : "";

          _actorController.text = (data['Actors'] ?? "").toString();
          _fetchedRating = (data['imdbRating'] ?? "N/A").toString();

          final String apiGenre = (data['Genre'] ?? "").toString();
          _selectedGenre = _mapOmdbGenreToTurkish(apiGenre);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Buldum! ✅"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Film bulunamadı")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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

    return cleaned.take(5).toList();
  }

  Future<void> _submitMovie() async {
    if (!_formKey.currentState!.validate()) return;

    if (_posterUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Önce filmi aratmalısın")));
      return;
    }

    final tags = _parseTags(_tagsController.text);
    if (tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("En az 1 anahtar kelime gir")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Oturum hatası");

      final movie = MovieModel(
        id: '',
        title: _titleController.text.trim(),
        posterUrl: _posterUrl,
        genre: _selectedGenre,
        actor: _actorController.text.trim(),
        plot: "",
        keywords: tags,
        addedBy: uid,
        status: 'pending',
        imdbRating: _fetchedRating,
      );

      await DatabaseService().addMovie(movie);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Film önerisi gönderildi! ✅"),
          backgroundColor: Colors.green,
        ),
      );

      _titleController.clear();
      _actorController.clear();
      _tagsController.clear();

      setState(() {
        _posterUrl = "";
        _fetchedRating = "N/A";
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _actorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text("Film Öner"),
        backgroundColor: const Color(0xFF0F111D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 220,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2232),
                    borderRadius: BorderRadius.circular(12),
                    image: _posterUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_posterUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _posterUrl.isEmpty
                      ? const Icon(Icons.movie_filter, color: Colors.grey)
                      : null,
                ),
              ),

              const SizedBox(height: 24),

              _buildLabel("Film Adı"),
              _buildSearchRow(),

              _buildLabel("Başrol Oyuncusu"),
              _buildTextField(_actorController, "Otomatik dolacak"),

              _buildLabel("Film Türü"),
              _buildGenreDropdown(),

              _buildLabel("Anahtar Kelimeler (max 5)"),
              _buildTextField(_tagsController, "uzay, savaş, aksiyon", max: 2),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMovie,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Listeye Ekle"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() => Row(
    children: [
      Expanded(
        child: _buildTextField(
          _titleController,
          "Şeytanın Avukatı / Inception",
          submit: (_) => _searchMovieFromApi(),
        ),
      ),
      const SizedBox(width: 10),
      IconButton(
        icon: _isSearching
            ? const CircularProgressIndicator()
            : const Icon(Icons.search),
        onPressed: _isSearching ? null : _searchMovieFromApi,
      ),
    ],
  );

  Widget _buildGenreDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFF1F2232),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedGenre,
        dropdownColor: const Color(0xFF1F2232),
        isExpanded: true,
        items: _genres
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => _selectedGenre = v!),
      ),
    ),
  );

  Widget _buildLabel(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      t,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildTextField(
    TextEditingController c,
    String hint, {
    int max = 1,
    Function(String)? submit,
  }) {
    return TextFormField(
      controller: c,
      maxLines: max,
      onFieldSubmitted: submit,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF1F2232),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? "Boş olamaz" : null,
    );
  }
}
