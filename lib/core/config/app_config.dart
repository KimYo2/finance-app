// lib/core/config/app_config.dart
// FILE INI TIDAK DI-COMMIT KE REPO

class AppConfig {
  AppConfig._();

  // ===== GROQ AI =====
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  // ===== POCKETBASE =====
  static const String pbBaseUrl = String.fromEnvironment(
    'PB_BASE_URL',
    defaultValue: 'https://equator-untainted-stank.ngrok-free.dev',
  );

  // ===== MIDTRANS =====
  static const String midtransClientKey = String.fromEnvironment(
    'MIDTRANS_CLIENT_KEY',
    defaultValue: '',
  );

  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // ===== HELPER =====
  static bool get isGroqConfigured =>
      groqApiKey.isNotEmpty &&
      !groqApiKey.contains('YOUR_') &&
      !groqApiKey.contains('ISI_');

  static bool get isPbConfigured =>
      pbBaseUrl.isNotEmpty && !pbBaseUrl.contains('YOUR_');

  // ===== EXISTING CONFIG =====
  static const bool isDemoBuild = false;

  static String get buildLabel => isDemoBuild ? 'DEMO' : '';

  static bool get allFeaturesUnlocked => isDemoBuild;
}
