import 'package:celebray/features/auth/domain/app_user.dart';
import 'package:celebray/features/auth/domain/ai_auth_session.dart';
import 'package:celebray/features/auth/domain/ai_auth_session_result.dart';
import 'package:celebray/features/auth/data/user_storage_service.dart';
import 'package:celebray/features/messages/ai_debug_log.dart';
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

  Future<AiAuthSessionResult> ensureAiSession() async {
    AiDebugLog.log('ensureAiSession: start');
    try {
      var user = _auth.currentUser;
      if (user == null) {
        AiDebugLog.log('ensureAiSession: no currentUser — signing in anonymously');
        final credential = await _auth.signInAnonymously();
        user = credential.user;
        AiDebugLog.log(
          'ensureAiSession: signInAnonymously done '
          'uid=${user?.uid ?? "null"} isAnonymous=${user?.isAnonymous}',
        );
      } else {
        AiDebugLog.log(
          'ensureAiSession: reusing currentUser '
          'uid=${user.uid} isAnonymous=${user.isAnonymous}',
        );
      }
      if (user == null) {
        AiDebugLog.error('ensureAiSession: user still null after sign-in');
        return const AiAuthSessionResult.failure(
          'Could not start a guest AI session. Try again.',
        );
      }

      final token = await user.getIdToken(true);
      AiDebugLog.log(
        'ensureAiSession: token refreshed '
        'len=${token?.length ?? 0} uid=${user.uid} isAnonymous=${user.isAnonymous}',
      );

      AiDebugLog.log('ensureAiSession: success');
      return AiAuthSessionResult.success(
        AiAuthSession(
          user: user,
          isAnonymous: user.isAnonymous,
        ),
      );
    } on FirebaseAuthException catch (error, stack) {
      AiDebugLog.error(
        'ensureAiSession FirebaseAuthException code=${error.code}',
        error.message,
        stack,
      );
      return AiAuthSessionResult.failure(_guestSessionErrorMessage(error));
    } catch (error, stack) {
      AiDebugLog.error('ensureAiSession unexpected failure', error, stack);
      return const AiAuthSessionResult.failure(
        'Guest AI is unavailable right now. Showing templates instead.',
      );
    }
  }

  String _guestSessionErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'operation-not-allowed':
        return 'Guest AI is off in Firebase. Enable Anonymous sign-in under '
            'Authentication → Sign-in method, then try again.';
      case 'network-request-failed':
        return 'No internet connection. Connect to use guest AI.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Wait a moment and try again.';
      default:
        return 'Guest AI sign-in failed (${error.code}). '
            'Showing template messages instead.';
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
