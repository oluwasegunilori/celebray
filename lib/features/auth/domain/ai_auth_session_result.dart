import 'package:celebray/features/auth/domain/ai_auth_session.dart';

class AiAuthSessionResult {
  final AiAuthSession? session;
  final String? failureMessage;

  const AiAuthSessionResult._({this.session, this.failureMessage});

  const AiAuthSessionResult.success(AiAuthSession session)
      : this._(session: session);

  const AiAuthSessionResult.failure(String message)
      : this._(failureMessage: message);

  bool get isSuccess => session != null;
}
