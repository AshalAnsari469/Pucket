import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_preference';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    bool isCurrentlyDark;
    if (state == ThemeMode.system) {
      isCurrentlyDark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    } else {
      isCurrentlyDark = state == ThemeMode.dark;
    }

    if (isCurrentlyDark) {
      state = ThemeMode.light;
      await prefs.setBool(_themeKey, false);
    } else {
      state = ThemeMode.dark;
      await prefs.setBool(_themeKey, true);
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
