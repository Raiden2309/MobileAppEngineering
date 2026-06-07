import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static Future<UserCredential> authenticate() async {
    final googleSignIn = GoogleSignIn();

    // Safely clear the active account state to force the picker UI,
    // without completely destroying the app's structural network cache.
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception("Google Sign-In canceled by user.");

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}