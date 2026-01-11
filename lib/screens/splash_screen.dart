import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    User? user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            user != null ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      size: 80,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Filmistik",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _opacity,
              child: Column(
                children: [
                  Text(
                    "from",
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "RAKOSOFT",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
