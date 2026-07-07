import 'package:celebray/features/auth/domain/app_user.dart';
import 'package:celebray/features/auth/domain/ai_auth_session.dart';
import 'package:celebray/features/auth/data/user_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  bool get isAnonymousUser => _auth.currentUser?.isAnonymous ?? false;

  bool get hasFullAccount =>
      _auth.currentUser != null && !(_auth.currentUser!.isAnonymous);

  Future<AppUser?> restoreSession() async {
    final storedUser = await UserStorageService.loadUser();
    if (hasFullAccount) return storedUser;

    if (storedUser != null) {
      await UserStorageService.clearUser();
    }
    return null;
  }

  Future<AiAuthSession?> ensureAiSession() async {
    try {
      var user = _auth.currentUser;
      if (user == null) {
        final credential = await _auth.signInAnonymously();
        user = credential.user;
      }
      if (user == null) return null;

      return AiAuthSession(
        user: user,
        isAnonymous: user.isAnonymous,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential> _signInOrLink(OAuthCredential credential) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        return await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'credential-already-in-use' ||
            error.code == 'email-already-in-use') {
          return await _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }

    return await _auth.signInWithCredential(credential);
  }

  Future<void> _persistAppUser(User firebaseUser, {AppUser? fallback}) async {
    final appUser = AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? fallback?.name,
      email: firebaseUser.email ?? fallback?.email,
      photoUrl: firebaseUser.photoURL ?? fallback?.photoUrl,
    );
    await UserStorageService.saveUser(appUser);
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

      final fallback = AppUser(
        uid: googleUser.id,
        name: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      final userCredential = await _signInOrLink(oauthCredential);
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _persistAppUser(firebaseUser, fallback: fallback);
      }

      return userCredential;
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

    final fallback = AppUser(
      uid: appleCredential.userIdentifier,
      name: appleCredential.givenName ?? '',
      email: appleCredential.email,
      photoUrl: null,
    );

    final userCredential = await _signInOrLink(oauthCredential);
    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      await _persistAppUser(firebaseUser, fallback: fallback);
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    await UserStorageService.clearUser();
  }
}
