import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/messages/message_generation_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageGenerationNotice extends StatelessWidget {
  final String? notice;
  final MessageGenerationSource? source;

  const MessageGenerationNotice({
    super.key,
    this.notice,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    if (notice == null && source != MessageGenerationSource.ai) {
      return const SizedBox.shrink();
    }

    final isSignedIn = FirebaseAuth.instance.currentUser != null;
    final showSignIn = !isSignedIn &&
        (notice?.toLowerCase().contains('sign in') ?? false);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: source == MessageGenerationSource.ai
            ? AppTheme.primaryLight
            : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (source == MessageGenerationSource.ai)
            const Text(
              'AI-generated',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          if (notice != null) ...[
            if (source == MessageGenerationSource.ai) const SizedBox(height: 4),
            Text(
              notice!,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.35,
              ),
            ),
          ],
          if (showSignIn) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/sign-in'),
              child: const Text('Sign in for AI messages'),
            ),
          ],
        ],
      ),
    );
  }
}
