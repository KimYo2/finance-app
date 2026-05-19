class UserSettings {
  final bool isDarkMode;
  final bool isPremium;
  final String preferredCurrency;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  const UserSettings({
    this.isDarkMode = false,
    this.isPremium = false,
    this.preferredCurrency = 'IDR',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
  });

  UserSettings copyWith({
    bool? isDarkMode,
    bool? isPremium,
    String? preferredCurrency,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPremium: isPremium ?? this.isPremium,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
