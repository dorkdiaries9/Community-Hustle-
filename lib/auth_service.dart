import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("✅ User data saved to Firestore");
        } else {
          print("ℹ️ User already exists in Firestore");
        }
      }

      return user;
    } catch (e) {
      print('❌ Google sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    print("✅ User signed out successfully");
  }
}
