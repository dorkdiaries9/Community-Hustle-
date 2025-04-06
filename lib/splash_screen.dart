import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'main_wrapper.dart'; // ✅ Required for navigation after login+onboarding

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2)); // ⏳ splash delay

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ User not signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else if (!onboardingCompleted) {
      // 🟡 First-time user → show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen(user: user)),
      );
    } else {
      // ✅ Signed in + onboarding done → go to app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainWrapper(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 🔄 Loader during delay
      ),
    );
  }
}
