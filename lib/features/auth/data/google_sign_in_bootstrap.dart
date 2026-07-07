import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInBootstrap {
  GoogleSignInBootstrap._();

  static const _iosClientId =
      '68778743183-mac6b1mcj9rt59q9evcr7o14p53rj5eq.apps.googleusercontent.com';
  static const _webClientId =
      '68778743183-c3qmhq9ajicfs5ilkv7qp326f9qcahll.apps.googleusercontent.com';

  static Future<void> initialize() async {
    await GoogleSignIn.instance.initialize(
      clientId: Platform.isIOS ? _iosClientId : null,
      serverClientId: _webClientId,
    );
  }
}
