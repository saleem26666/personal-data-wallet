import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.themeModeName,
    required this.idleLockSeconds,
    required this.lockOnBackground,
    required this.biometricEnabled,
    required this.clipboardSeconds,
  });

  final String themeModeName;
  final int idleLockSeconds;
  final bool lockOnBackground;
  final bool biometricEnabled;
  final int clipboardSeconds;

  AppSettings copyWith({
    String? themeModeName,
    int? idleLockSeconds,
    bool? lockOnBackground,
    bool? biometricEnabled,
    int? clipboardSeconds,
  }) {
    return AppSettings(
      themeModeName: themeModeName ?? this.themeModeName,
      idleLockSeconds: idleLockSeconds ?? this.idleLockSeconds,
      lockOnBackground: lockOnBackground ?? this.lockOnBackground,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      clipboardSeconds: clipboardSeconds ?? this.clipboardSeconds,
    );
  }

  static const defaults = AppSettings(
    themeModeName: 'system',
    idleLockSeconds: 120,
    lockOnBackground: true,
    biometricEnabled: false,
    clipboardSeconds: 30,
  );
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static AppSettings _read(SharedPreferences prefs) {
    return AppSettings(
      themeModeName: prefs.getString('themeMode') ?? 'system',
      idleLockSeconds: prefs.getInt('idleLockSeconds') ?? 120,
      lockOnBackground: prefs.getBool('lockOnBackground') ?? true,
      biometricEnabled: prefs.getBool('biometricEnabled') ?? false,
      clipboardSeconds: prefs.getInt('clipboardSeconds') ?? 30,
    );
  }

  Future<void> setThemeMode(String name) async {
    await _prefs.setString('themeMode', name);
    state = state.copyWith(themeModeName: name);
  }

  Future<void> setIdleLockSeconds(int seconds) async {
    await _prefs.setInt('idleLockSeconds', seconds);
    state = state.copyWith(idleLockSeconds: seconds);
  }

  Future<void> setLockOnBackground(bool value) async {
    await _prefs.setBool('lockOnBackground', value);
    state = state.copyWith(lockOnBackground: value);
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool('biometricEnabled', value);
    state = state.copyWith(biometricEnabled: value);
  }

  Future<void> setClipboardSeconds(int seconds) async {
    await _prefs.setInt('clipboardSeconds', seconds);
    state = state.copyWith(clipboardSeconds: seconds);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(sharedPreferencesProvider));
});
