import 'package:community_hustle_flutter/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ for auth
import 'package:shared_preferences/shared_preferences.dart'; // ✅ for onboarding check
import 'screens/splash_screen.dart'; // your splash screen
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAJqNIkrPQ0wlzz81-85ausBdmFvdfVwrk",
        authDomain: "communityhustleweb.firebaseapp.com",
        projectId: "communityhustleweb",
        storageBucket: "communityhustleweb.appspot.com",
        messagingSenderId: "932943493749",
        appId: "1:932943493749:web:0b2498dbac15700f3d163c",
        measurementId: "G-23DWCLT12C",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  print("✅ Firebase initialized successfully!");

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ your first screen
    ),
  );
}
