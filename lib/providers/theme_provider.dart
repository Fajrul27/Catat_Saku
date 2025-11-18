import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const _themeModeKey = 'themeMode';

  AppThemeMode _themeMode = AppThemeMode.system;
  Brightness _platformBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  AppThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == AppThemeMode.dark) return true;
    if (_themeMode == AppThemeMode.light) return false;
    return _platformBrightness == Brightness.dark;
  }

  ThemeMode get effectiveThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    if (modeString != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == modeString,
        orElse: () => AppThemeMode.system,
      );
    }
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_themeMode == AppThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Light Theme
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF5D5FEF),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D5FEF),
          primary: const Color(0xFF5D5FEF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1B1B1B),
          elevation: 0,
        ),
      );

  // Dark Theme
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8E90FF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E90FF),
          primary: const Color(0xFF8E90FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );

  // Helper untuk warna dinamis
  Color getBackgroundColor(bool isDark) =>
      isDark ? const Color(0xFF121212) : Colors.white;
  Color getCardColor(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7);
  Color getTextColor(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1B1B1B);
  Color getSecondaryTextColor(bool isDark) =>
      isDark ? Colors.white70 : const Color(0xFF1B1B1B).withOpacity(0.5);
}
