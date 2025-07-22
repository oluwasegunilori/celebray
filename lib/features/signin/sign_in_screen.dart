import 'package:celebray/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignedIn;

  const SignInScreen({required this.onSignedIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _auth = AuthService();
  bool _loading = false;

  void _signInWithGoogle() async {
    setState(() => _loading = true);
    final userCred = await _auth.signInWithGoogle();
    setState(() => _loading = false);

    if (userCred != null) {
      await _saveOnboardingPreference();
      widget.onSignedIn();
    }
  }

  void _signInWithApple() async {
    setState(() => _loading = true);
    try {
      final userCred = await _auth.signInWithApple();
      if (userCred != null) {
        await _saveOnboardingPreference();
        widget.onSignedIn();
      }
    } catch (e) {
      // Handle user cancel or failure
      print("Sign in with Apple failed: $e");
    }
    setState(() => _loading = false);
  }

  void _skipSignIn() {
    widget.onSignedIn();
  }

  Future<void> _saveOnboardingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In or Skip")),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: Image.asset('assets/google_logo.png', height: 24),
                      label: Text("Continue with Google"),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      SizedBox(height: 16),
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      ElevatedButton.icon(
                        icon: Icon(Icons.apple),
                        label: Text("Continue with Apple"),
                        onPressed: _signInWithApple,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    SizedBox(height: 32),
                    Text("or", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: _skipSignIn,
                      child: Text("Continue without signing in"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
