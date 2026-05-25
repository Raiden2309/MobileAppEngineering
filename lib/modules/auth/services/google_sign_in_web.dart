import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInService {
  static Future<UserCredential> authenticate() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }
}