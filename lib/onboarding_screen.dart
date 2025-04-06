import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  final User user;
  const OnboardingScreen({super.key, required this.user});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Community Hustle',
      'description': 'Join hands to volunteer with verified NGOs across India.',
      'image': 'assets/images/onboard1.jpg',
    },
    {
      'title': 'Make a Real Difference',
      'description': 'Track your impact and hours served. Every action counts!',
      'image': 'assets/images/onboard2.jpg',
    },
    {
      'title': 'Get Started Today',
      'description': 'Find causes you care about and start volunteering.',
      'image': 'assets/images/onboard3.jpg',
    },
  ];

  Future<void> completeOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainWrapper(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingData.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final data = onboardingData[index];

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: Image.asset(
                    data['image']!,
                    fit: BoxFit.contain,
                    semanticLabel: data['title'],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  data['title']!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  data['description']!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (dotIndex) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == dotIndex ? 12 : 8,
                      height: _currentPage == dotIndex ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == dotIndex
                            ? Colors.deepPurple
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_currentPage == onboardingData.length - 1) {
                            completeOnboarding();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : completeOnboarding,
                  child: const Text('Skip'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
