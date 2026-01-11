import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/movie_model.dart';
import 'movie_detail_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  Map<dynamic, dynamic>? _userData;
  List<MovieModel> _favoriteMovies = [];
  List<MovieModel> _contributedMovies = [];

  bool _isLoading = true;

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fetchUserData();
    _fetchMovies();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseDatabase.instance.ref('users/${user.uid}/role');
      final snap = await ref.get();

      if (!mounted) return;
      setState(() => _isAdmin = snap.value == "admin");
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final ref = FirebaseDatabase.instance.ref('users/${currentUser.uid}');
      final snapshot = await ref.get();
      if (mounted && snapshot.exists) {
        setState(() {
          _userData = snapshot.value as Map;
        });
      }
    }
  }

  Future<void> _fetchMovies() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final favRef = FirebaseDatabase.instance.ref(
          'users/${currentUser.uid}/favorites',
        );
        final favSnapshot = await favRef.get();
        List<String> favMovieIds = [];
        if (favSnapshot.exists) {
          final favMap = favSnapshot.value as Map<dynamic, dynamic>;
          favMovieIds = favMap.keys.cast<String>().toList();
        }

        final movieRef = FirebaseDatabase.instance.ref('movies');
        final movieSnapshot = await movieRef.get();

        List<MovieModel> loadedFavs = [];
        List<MovieModel> loadedContributions = [];

        if (movieSnapshot.exists) {
          final data = movieSnapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            final movieMap = Map<String, dynamic>.from(value);
            final movie = MovieModel.fromMap(movieMap).copyWith(id: key);

            if (favMovieIds.contains(key)) loadedFavs.add(movie);
            if (movie.addedBy == currentUser.uid)
              loadedContributions.add(movie);
          });
        }

        if (mounted) {
          setState(() {
            _favoriteMovies = loadedFavs;
            _contributedMovies = loadedContributions;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Veri çekme hatası: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text(
          "Profilim",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F111D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              tooltip: "Yönetici Paneli",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: "Bildirimler",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blueAccent),
            tooltip: "Ayarlar",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    _userData?['name'] != null
                        ? _userData!['name'][0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "@${_userData?['username'] ?? 'kullanici'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData?['name'] ?? "İsimsiz",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF2563EB),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Katkılarım"),
                    Tab(text: "Kaydettiklerim"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMovieGrid(
                        _contributedMovies,
                        "Henüz film eklemedin.",
                      ),
                      _buildMovieGrid(_favoriteMovies, "Henüz favorin yok."),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMovieGrid(List<MovieModel> movies, String emptyMessage) {
    if (movies.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
