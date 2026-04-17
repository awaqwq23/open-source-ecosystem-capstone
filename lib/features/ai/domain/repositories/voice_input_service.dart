abstract class VoiceInputService {
  Future<bool> isSupported();

  Future<bool> startListening({
    required String localeId,
  });

  Future<String?> stopListening();
}
