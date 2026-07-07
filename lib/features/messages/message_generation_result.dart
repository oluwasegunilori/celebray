enum MessageGenerationSource { ai, template }

class MessageGenerationResult {
  final List<String> messages;
  final MessageGenerationSource source;
  final String? notice;

  const MessageGenerationResult({
    required this.messages,
    required this.source,
    this.notice,
  });
}
