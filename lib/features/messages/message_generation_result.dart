enum MessageGenerationSource { ai, template }

class MessageGenerationResult {
  final List<String> messages;
  final MessageGenerationSource source;
  final String? notice;
  final bool refused;

  const MessageGenerationResult({
    required this.messages,
    required this.source,
    this.notice,
    this.refused = false,
  });
}
