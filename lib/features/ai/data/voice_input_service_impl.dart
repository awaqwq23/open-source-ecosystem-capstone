import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/voice_input_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class UnsupportedVoiceInputService implements VoiceInputService {
  const UnsupportedVoiceInputService();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> startListening({
    required String localeId,
  }) async {
    return false;
  }

  @override
  Future<String?> stopListening() async => null;
}

class MobileVoiceInputService implements VoiceInputService {
  MobileVoiceInputService() : _speech = SpeechToText();

  final SpeechToText _speech;
  String _transcript = '';
  bool _initialized = false;

  @override
  Future<bool> isSupported() async {
    if (!_isMobilePlatform) {
      return false;
    }
    if (_initialized) {
      return true;
    }
    _initialized = await _speech.initialize();
    return _initialized;
  }

  @override
  Future<bool> startListening({
    required String localeId,
  }) async {
    final supported = await isSupported();
    if (!supported) {
      return false;
    }
    _transcript = '';
    return _speech.listen(
      localeId: localeId,
      onResult: (result) {
        _transcript = result.recognizedWords.trim();
      },
      partialResults: true,
    );
  }

  @override
  Future<String?> stopListening() async {
    if (!_initialized) {
      return null;
    }
    await _speech.stop();
    final finalText = _transcript.trim();
    _transcript = '';
    return finalText.isEmpty ? null : finalText;
  }

  bool get _isMobilePlatform {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}

final voiceInputServiceProvider = Provider<VoiceInputService>((ref) {
  if (kIsWeb) {
    return const UnsupportedVoiceInputService();
  }
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
    return MobileVoiceInputService();
  }
  return const UnsupportedVoiceInputService();
});
