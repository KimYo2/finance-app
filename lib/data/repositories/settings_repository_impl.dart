import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../core/config/app_config.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyPremium = 'usage_is_premium';
  static const String _keyCurrency = 'preferred_currency';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometric = 'biometric_enabled';

  @override
  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      isDarkMode: prefs.getBool(_keyDarkMode) ?? false,
      isPremium: AppConfig.allFeaturesUnlocked
          ? true
          : (prefs.getBool(_keyPremium) ?? false),
      preferredCurrency: prefs.getString(_keyCurrency) ?? 'IDR',
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      biometricEnabled: prefs.getBool(_keyBiometric) ?? false,
    );
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, settings.isDarkMode);
    await prefs.setBool(_keyPremium, settings.isPremium);
    await prefs.setString(_keyCurrency, settings.preferredCurrency);
    await prefs.setBool(_keyNotifications, settings.notificationsEnabled);
    await prefs.setBool(_keyBiometric, settings.biometricEnabled);
  }

  @override
  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_keyDarkMode) ?? false;
    await prefs.setBool(_keyDarkMode, !current);
  }

  @override
  Future<void> toggleBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_keyBiometric) ?? false;
    await prefs.setBool(_keyBiometric, !current);
  }

  @override
  Future<void> setPreferredCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
  }
}
