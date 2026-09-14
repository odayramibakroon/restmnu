import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../errors/error_messages.dart';
import '../storage/local_storage_keys.dart';
import '../storage/local_storage_service.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';

  ThemeState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}

class ThemeCubit extends Cubit<ThemeState> {
  final LocalStorageService localStorage;

  ThemeCubit({required this.localStorage}) : super(const ThemeState());

  Future<void> restorePreferences() async {
    if (isClosed) return;

    try {
      final localeCode = await localStorage.readString(
        LocalStorageKeys.localeCode,
        errorKey: AppErrorKey.loadUserPreferencesFromLocalStorage,
      );
      final themeMode = await localStorage.readString(
        LocalStorageKeys.themeMode,
        errorKey: AppErrorKey.loadUserPreferencesFromLocalStorage,
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          locale: _localeFromCode(localeCode),
          themeMode: _themeModeFromCode(themeMode),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void toggleTheme() {
    if (isClosed) return;
    setThemeMode(state.isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) {
    if (isClosed) return;
    emit(state.copyWith(themeMode: mode));
    _savePreference(LocalStorageKeys.themeMode, _themeModeCode(mode));
  }

  void toggleLocale() {
    if (isClosed) return;
    setLocale(state.isArabic ? const Locale('en') : const Locale('ar'));
  }

  void setLocale(Locale locale) {
    if (isClosed) return;
    emit(state.copyWith(locale: locale));
    _savePreference(LocalStorageKeys.localeCode, locale.languageCode);
  }

  void _savePreference(String key, String value) {
    localStorage
        .writeString(
          key,
          value,
          errorKey: AppErrorKey.saveUserPreferencesToLocalStorage,
        )
        .catchError((Object e) => debugPrint(e.toString()));
  }

  Locale _localeFromCode(String? code) {
    return code == 'en' ? const Locale('en') : const Locale('ar');
  }

  ThemeMode _themeModeFromCode(String? code) {
    return code == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  String _themeModeCode(ThemeMode mode) {
    return mode == ThemeMode.dark ? 'dark' : 'light';
  }
}
