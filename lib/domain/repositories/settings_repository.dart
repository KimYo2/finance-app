import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateSettings(UserSettings settings);
  Future<void> toggleDarkMode();
  Future<void> toggleBiometric();
  Future<void> setPreferredCurrency(String currency);
}
