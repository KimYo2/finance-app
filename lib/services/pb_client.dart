import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../config/app_config.dart';

class _NgrokHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['ngrok-skip-browser-warning'] = 'true';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

class PbClient {
  static PocketBase? _instance;
  static String? _currentUrl;

  static PocketBase get instance {
    final baseUrl = _baseUrl;
    if (_instance == null || _currentUrl != baseUrl) {
      _instance = PocketBase(
        baseUrl,
        httpClientFactory: () => _NgrokHttpClient(),
      );
      _currentUrl = baseUrl;
    }
    return _instance!;
  }

  static String get _baseUrl {
    final fromDefine = String.fromEnvironment('PB_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;

    if (AppConfig.pbBaseUrl.isNotEmpty) return AppConfig.pbBaseUrl;

    if (kIsWeb) {
      return 'http://localhost:8090';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
    }

    if (Platform.isIOS) {
      return 'http://127.0.0.1:8090';
    }

    return 'http://localhost:8090';
  }

  static Future<bool> isConnected() async {
    try {
      await instance.health.check();
      return true;
    } catch (_) {
      return false;
    }
  }

  static void reset() {
    _instance = null;
    _currentUrl = null;
  }
}
