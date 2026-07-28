import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/di/service_locator.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/storage_keys.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/phone_frame.dart';
import '../l10n/app_localizations.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class QariVerseApp extends StatelessWidget {
  const QariVerseApp({super.key});

  static Locale _localeFromCode(String code) {
    switch (code) {
      case 'ara': return const Locale('ar');
      case 'fra': return const Locale('fr');
      case 'urd': return const Locale('ur');
      case 'ind': return const Locale('id');
      case 'mly': return const Locale('ms');
      case 'tur': return const Locale('tr');
      case 'rus': return const Locale('ru');
      default:    return const Locale('en');
    }
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = sl<LocalStorageService>();
    final saved = storage.readJson(StorageKeys.settings);
    final initialLocale = _localeFromCode((saved?['language'] as String?) ?? 'eng');
    final initialThemeMode = _themeModeFromString((saved?['themeMode'] as String?) ?? 'system');

    return GetMaterialApp(
      title: 'QariVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: initialThemeMode,
      locale: initialLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
        Locale('ur'),
        Locale('id'),
        Locale('ms'),
        Locale('tr'),
        Locale('ru'),
      ],
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) => PhoneFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
