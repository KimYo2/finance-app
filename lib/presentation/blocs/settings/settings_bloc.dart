import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsToggleDarkMode>(_onToggleDarkMode);
    on<SettingsToggleBiometric>(_onToggleBiometric);
    on<SettingsToggleNotifications>(_onToggleNotifications);
    on<SettingsSetCurrency>(_onSetCurrency);
    on<SettingsUpgradeToPremium>(_onUpgradeToPremium);
  }

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      debugPrint('[SettingsBloc] load error: $e');
      emit(const SettingsError(message: 'Gagal memuat pengaturan'));
    }
  }

  Future<void> _emitReloaded(Emitter<SettingsState> emit) async {
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      debugPrint('[SettingsBloc] reload error: $e');
    }
  }

  Future<void> _onToggleDarkMode(
    SettingsToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.toggleDarkMode();
    await _emitReloaded(emit);
  }

  Future<void> _onToggleBiometric(
    SettingsToggleBiometric event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.toggleBiometric();
    await _emitReloaded(emit);
  }

  Future<void> _onToggleNotifications(
    SettingsToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final current = await _settingsRepository.getSettings();
    final updated = current.copyWith(
      notificationsEnabled: !current.notificationsEnabled,
    );
    await _settingsRepository.updateSettings(updated);
    await _emitReloaded(emit);
  }

  Future<void> _onSetCurrency(
    SettingsSetCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.setPreferredCurrency(event.currency);
    await _emitReloaded(emit);
  }

  Future<void> _onUpgradeToPremium(
    SettingsUpgradeToPremium event,
    Emitter<SettingsState> emit,
  ) async {
    final current = await _settingsRepository.getSettings();
    final updated = current.copyWith(isPremium: true);
    await _settingsRepository.updateSettings(updated);
    await _emitReloaded(emit);
  }
}
