import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  Function()? _onListeningStopCallback;
  bool _callbackCalled = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => _handleError(error),
      onStatus: (status) {
        debugPrint('Voice status: $status');
        if (status == 'done' || status == 'notListening') {
          if (_isListening && !_callbackCalled) {
            _callbackCalled = true;
            _isListening = false;
            _onListeningStopCallback?.call();
          }
        }
      },
    );
    return _isInitialized;
  }

  void _handleError(SpeechRecognitionError error) {
    _isListening = false;
    _callbackCalled = true;

    String message;
    switch (error.errorMsg) {
      case 'error_no_match':
        message = 'Tidak terdengar, coba ulangi';
        break;
      case 'error_speech_timeout':
        message = 'Terlalu lama diam, coba lagi';
        break;
      case 'error_network':
        message = 'Butuh koneksi internet untuk voice recognition';
        break;
      case 'error_permission':
        message = 'Izin mikrofon diperlukan';
        break;
      default:
        message = 'Error: ${error.errorMsg}';
    }
    debugPrint('Voice error: $message');
  }

  /// Cari locale Bahasa Indonesia secara prioritas.
  /// Return `id_ID` jika ada, fallback ke `id_*`, null jika tidak ada.
  String? _findIndonesianLocale(List<LocaleName> locales) {
    // Cari id_ID exact
    final exact = locales.cast<LocaleName?>().firstWhere(
      (l) => l!.localeId == 'id_ID',
      orElse: () => null,
    );
    if (exact != null) return exact.localeId;

    // Cari id_* lainnya (id, in_ID, dll)
    final any = locales.cast<LocaleName?>().firstWhere(
      (l) => l!.localeId.startsWith('id'),
      orElse: () => null,
    );
    if (any != null) return any.localeId;

    return null;
  }

  final Map<String, int> _units = {
    'nol': 0, 'satu': 1, 'dua': 2, 'tiga': 3, 'empat': 4,
    'lima': 5, 'enam': 6, 'tujuh': 7, 'delapan': 8, 'sembilan': 9,
    'sepuluh': 10, 'sebelas': 11,
  };

  final Map<String, int> _teens = {
    'dua belas': 12, 'tiga belas': 13, 'empat belas': 14,
    'lima belas': 15, 'enam belas': 16, 'tujuh belas': 17,
    'delapan belas': 18, 'sembilan belas': 19,
  };

  final Map<String, int> _scales = {
    'rb': 1000, 'ribu': 1000,
    'juta': 1000000, 'jt': 1000000,
    'miliar': 1000000000, 'milyar': 1000000000,
  };

  /// Konversi angka dalam Bahasa Indonesia ke digit numerik.
  ///
  /// Contoh:
  /// - "tiga puluh lima ribu" → "35000"
  /// - "dua juta lima ratus ribu" → "2500000"
  /// - "lima belas rb" → "15000"
  /// - "10rb" → "10000"
  /// - "1,5 juta" → "1500000"
  String normalizeIndonesianNumbers(String text) {
    if (text.isEmpty) return text;
    String r = text.toLowerCase();

    // 1. "xxrb" / "xx ribu" — compact digit+scale
    r = r.replaceAllMapped(
      RegExp(r'(\d+)\s*(rb|ribu)\b'), (m) => '${int.parse(m.group(1)!) * 1000}',
    );

    // 2. "x,x scale" — decimal + scale
    r = r.replaceAllMapped(
      RegExp(r'(\d+)[.,](\d+)\s*(juta|jt|rb|ribu|miliar)\b'), (m) {
        final whole = int.parse(m[1]!);
        final frac = int.parse(m[2]!);
        final scale = _scales[m[3]!]!;
        final div = _pow10(m[2]!.length);
        return '${((whole + frac / div) * scale).round()}';
      },
    );

    // 3. teens
    for (final e in _teens.entries) {
      r = r.replaceAll(e.key, '${e.value}');
    }

    // 4. puluhan: "dua puluh lima" → 25
    r = r.replaceAllMapped(
      RegExp(r'(\w+)\s+puluh(?:\s+(\w+))?'), (m) {
        final t = _units[m[1]!] ?? 0;
        final o = m.group(2) != null ? (_units[m[2]!] ?? 0) : 0;
        return t > 0 ? '${t * 10 + o}' : m[0]!;
      },
    );
    r = r.replaceAllMapped(
      RegExp(r'\bsepuluh\b'), (m) => '10',
    );

    // 5. ratusan: "dua ratus" → 200, "seratus" → 100
    r = r.replaceAllMapped(
      RegExp(r'(seratus|(\w+)\s+ratus(?:\s+(\w+))?)'), (m) {
        if (m[1] == 'seratus') {
          final rest = m.group(3) != null ? (_units[m[3]!] ?? 0) : 0;
          return '${100 + rest}';
        }
        final h = _units[m[2]!] ?? 0;
        final rest = m.group(3) != null ? (_units[m[3]!] ?? 0) : 0;
        return h > 0 ? '${h * 100 + rest}' : m[0]!;
      },
    );

    // 6. ribuan word: "seribu" → 1000, "dua ribu" → 2000
    r = r.replaceAllMapped(
      RegExp(r'(seribu|(\w+)\s+ribu(?:\s+(\w+))?)'), (m) {
        if (m[1] == 'seribu') return '1000';
        final t = _units[m[2]!] ?? 0;
        final rest = m.group(3) != null ? (_units[m[3]!] ?? 0) : 0;
        return t > 0 ? '${t * 1000 + rest}' : m[0]!;
      },
    );

    // 7. jutaan: "satu juta" → 1000000, "dua juta" → 2000000
    r = r.replaceAllMapped(
      RegExp(r'(satu\s+)?juta(?:\s+(\w+))?'), (m) {
        final rest = m.group(2) != null ? (_units[m[2]!] ?? 0) : 0;
        return '${1000000 + rest}';
      },
    );

    // 8. Scale multiply for any remaining digit+scale (catches
    //    results from steps 4-7, e.g. "300 ribu" → "300000")
    for (final e in _scales.entries) {
      r = r.replaceAllMapped(
        RegExp(r'(\d+)\s*${e.key}\b'),
        (m) => '${int.parse(m[1]!) * e.value}',
      );
    }

    // 9. Single word digits (satu → 1, etc) — last to avoid conflicts
    for (final e in _units.entries) {
      r = r.replaceAllMapped(
        RegExp('\\b${e.key}\\b'), (_) => '${e.value}',
      );
    }

    return r;
  }

  int _pow10(int n) {
    int r = 1;
    for (int i = 0; i < n; i++) r *= 10;
    return r;
  }

  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
    required Function() onListeningStart,
    required Function() onListeningStop,
    Function(String)? onLocaleWarning,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    if (_isListening) return;

    _callbackCalled = false;
    _onListeningStopCallback = onListeningStop;
    _isListening = true;
    onListeningStart();

    final locales = await _speech.locales();
    final indonesianLocale = _findIndonesianLocale(locales);
    final selectedLocale = indonesianLocale ?? '';

    if (indonesianLocale == null && onLocaleWarning != null) {
      onLocaleWarning(
        'Bahasa Indonesia belum terinstall di perangkat ini.\n\n'
        'Android: Buka Settings → System → Languages → Add Indonesian\n'
        'iOS: Buka Settings → General → Language & Region → Add Indonesian\n\n'
        'Voice akan menggunakan bahasa default device.',
      );
    }

    await _speech.listen(
      onResult: onResult,
      localeId: selectedLocale,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    _callbackCalled = true;
    final callback = _onListeningStopCallback;
    _onListeningStopCallback = null;
    await _speech.stop();
    callback?.call();
  }

  Future<void> cancelListening() async {
    _isListening = false;
    _callbackCalled = true;
    await _speech.cancel();
    _onListeningStopCallback?.call();
    _onListeningStopCallback = null;
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    return await _speech.locales();
  }
}
