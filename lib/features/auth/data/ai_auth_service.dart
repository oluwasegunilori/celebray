import 'package:celebray/features/auth/data/auth_service.dart';
import 'package:celebray/features/auth/domain/ai_auth_session_result.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAuthService {
  AiAuthService._();

  static final AuthService _authService = AuthService();

  static Future<AiAuthSessionResult> ensureSession() async {
    return _authService.ensureAiSession();
  }

  static bool get isGuest =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  static bool get hasFullAccount {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }
}
