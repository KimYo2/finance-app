import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class SettingsToggleDarkMode extends SettingsEvent {
  const SettingsToggleDarkMode();
}

class SettingsToggleBiometric extends SettingsEvent {
  const SettingsToggleBiometric();
}

class SettingsToggleNotifications extends SettingsEvent {
  const SettingsToggleNotifications();
}

class SettingsSetCurrency extends SettingsEvent {
  final String currency;

  const SettingsSetCurrency({required this.currency});

  @override
  List<Object?> get props => [currency];
}

class SettingsUpgradeToPremium extends SettingsEvent {
  const SettingsUpgradeToPremium();
}
