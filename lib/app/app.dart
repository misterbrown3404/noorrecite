import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/di/service_locator.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/storage_keys.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_mappers.dart';
import '../core/widgets/widgets.dart';
import '../l10n/app_localizations.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class QariVerseApp extends StatelessWidget {
  const QariVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = sl<LocalStorageService>();
    final saved = storage.readJson(StorageKeys.settings);
    final initialLocale =
        AppMappers.localeFromCode((saved?['language'] as String?) ?? 'eng');
    final initialThemeMode = AppMappers
        .themeModeFromString((saved?['themeMode'] as String?) ?? 'system');

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
      builder: (context, child) => PhoneFrame(
        // Offline banner lives above the Navigator so it spans every route,
        // collapsing to nothing while online. Column (not Stack) so it pushes
        // content down rather than covering an AppBar when it appears.
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
