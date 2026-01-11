import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_model.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  List<String> _normalizeKeywords(List<String> input) {
    final out = <String>[];
    for (final item in input) {
      final parts = item
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      out.addAll(parts);
    }

    final seen = <String>{};
    final unique = <String>[];
    for (final t in out) {
      final key = t.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(t);
      }
    }

    return unique;
  }

  void _checkIfFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref(
        'users/${user.uid}/favorites/${widget.movie.id}',
      );
      final snapshot = await ref.get();
      if (mounted && snapshot.exists) {
        setState(() => _isFavorite = true);
      }
    }
  }

  void _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref(
      'users/${user.uid}/favorites/${widget.movie.id}',
    );
    if (_isFavorite) {
      await ref.remove();
      if (mounted) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Favorilerden çıkarıldı 💔"),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await ref.set(true);
      if (mounted) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Favorilere eklendi ❤️"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _launchTrailer() async {
    final movieName = widget.movie.title;
    final Uri url = Uri.parse(
      'https://www.youtube.com/results?search_query=$movieName+trailer',
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Link açılamadı');
      }
    } catch (e) {
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fragman bulunamadı 😔")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedTags = _normalizeKeywords(
      widget.movie.keywords,
    ).take(5).toList();
    final hasTags = normalizedTags.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.redAccent : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 450,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      widget.movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(color: Colors.black),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F111D).withOpacity(0.5),
                            const Color(0xFF0F111D),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 160,
                          width: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(widget.movie.posterUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.movie.genre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.movie.imdbRating != "N/A"
                                        ? widget.movie.imdbRating
                                        : "-",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey[400],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "2s 14d",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _launchTrailer,
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  label: const Text(
                    "Fragmanı İzle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Özet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.plot.isNotEmpty
                        ? widget.movie.plot
                        : "Özet bulunamadı.",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Anahtar Kelimeler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  hasTags
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: normalizedTags.map((k) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2232),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                k,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          "Anahtar kelime eklenmemiş.",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Oyuncular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2232),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.actor,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                "Başrol",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
