import 'package:celebray/models/app_user.dart';
import 'package:celebray/services/user_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null; // User canceled

      final googleAuth = googleUser.authentication;

      final oauthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final appUser = AppUser(
        uid: googleUser.id,
        name: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      UserStorageService.saveUser(appUser);

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  // Apple sign-in
  Future<UserCredential?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final appUser = AppUser(
      uid: appleCredential.userIdentifier,
      name: appleCredential.givenName ?? '',
      email: appleCredential.email,
      photoUrl: null, // Apple sign-in does not provide a photo URL
    );

    UserStorageService.saveUser(appUser);

    return await _auth.signInWithCredential(oauthCredential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
