import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/movie_model.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchQuery = "";
  String _selectedCategory = "Tümü";

  final List<String> _categories = [
    "Tümü",
    "Bilim Kurgu",
    "Aksiyon",
    "Dram",
    "Korku",
    "Komedi",
    "Fantastik",
    "Romantik",
  ];

  String _norm(String input) {
    final fixed = input.replaceAll('İ', 'i').replaceAll('I', 'ı');
    return fixed.toLowerCase().trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('movies').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchHeaderDelegate(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (v) => setState(() => _searchQuery = _norm(v)),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _CategoryHeaderDelegate(
                      categories: _categories,
                      selected: _selectedCategory,
                      onTap: (c) => setState(() => _selectedCategory = c),
                    ),
                  ),
                  SliverFillRemaining(child: _buildEmptyState()),
                ],
              );
            }

            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final List<MovieModel> allMovies = [];

            data.forEach((key, value) {
              final movieMap = Map<String, dynamic>.from(value);
              allMovies.add(MovieModel.fromMap(movieMap).copyWith(id: key));
            });

            final filteredMovies = allMovies.where((movie) {
              if (movie.status != 'approved') return false;

              if (_selectedCategory != "Tümü" &&
                  movie.genre != _selectedCategory) {
                return false;
              }

              if (_searchQuery.isNotEmpty) {
                final title = _norm(movie.title);
                final actor = _norm(movie.actor);
                final tagsText = _norm(movie.keywords.join(' '));

                final matchesSearch =
                    title.contains(_searchQuery) ||
                    actor.contains(_searchQuery) ||
                    tagsText.contains(_searchQuery);

                if (!matchesSearch) return false;
              }

              return true;
            }).toList();

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (v) => setState(() => _searchQuery = _norm(v)),
                  ),
                ),

                SliverPersistentHeader(
                  pinned: false,
                  delegate: _CategoryHeaderDelegate(
                    categories: _categories,
                    selected: _selectedCategory,
                    onTap: (c) => setState(() => _selectedCategory = c),
                  ),
                ),

                if (filteredMovies.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildMovieCard(context, filteredMovies[index]),
                        childCount: filteredMovies.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 60,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          const Text(
            "Film bulunamadı 🎬",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, MovieModel movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2232),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.imdbRating != "N/A"
                                  ? movie.imdbRating
                                  : "-",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    style: TextStyle(
                      color: Colors.blueAccent[100],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  _SearchHeaderDelegate({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF0F111D),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Film, oyuncu veya anahtar kelime ara...",
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1F2232),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) => true;
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onTap;

  _CategoryHeaderDelegate({
    required this.categories,
    required this.selected,
    required this.onTap,
  });

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final opacity = (1.0 - t);

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: maxExtent,
        child: Container(
          color: const Color(0xFF0F111D),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selected == category;

              return GestureDetector(
                onTap: () => onTap(category),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF1F2232),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.categories.length != categories.length;
  }
}
