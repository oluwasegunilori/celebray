import 'package:firebase_auth/firebase_auth.dart';

class AiAuthSession {
  final User user;
  final bool isAnonymous;

  const AiAuthSession({
    required this.user,
    required this.isAnonymous,
  });
}
