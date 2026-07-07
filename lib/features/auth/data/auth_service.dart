import 'package:celebray/features/auth/domain/app_user.dart';
import 'package:celebray/features/auth/data/user_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> restoreSession() async {
    final storedUser = await UserStorageService.loadUser();
    if (_auth.currentUser != null) return storedUser;

    if (storedUser != null) {
      await UserStorageService.clearUser();
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) return null;

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

      await UserStorageService.saveUser(appUser);

      return await _auth.signInWithCredential(oauthCredential);
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final appUser = AppUser(
      uid: appleCredential.userIdentifier,
      name: appleCredential.givenName ?? '',
      email: appleCredential.email,
      photoUrl: null,
    );

    await UserStorageService.saveUser(appUser);

    return await _auth.signInWithCredential(oauthCredential);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    await UserStorageService.clearUser();
  }
}
