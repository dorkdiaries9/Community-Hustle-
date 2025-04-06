import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../screens/main_wrapper.dart';
import '../screens/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);
    final user = await AuthService.signInWithGoogle();
    setState(() => isLoading = false);

    if (user != null) {
      print('✅ Logged in as ${user.displayName}');

      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_completed') ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => completed
              ? MainWrapper(user: user)
              : OnboardingScreen(user: user),
        ),
      );
    } else {
      print('⚠️ Login failed or cancelled');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: 1.0,
                  child: Image.asset(
                    'assets/images/volunteer_login.png',
                    height: size.height * 0.3,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 28,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
