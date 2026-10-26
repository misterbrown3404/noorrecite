import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';

/// Settings screen with profile header and app settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        toolbarHeight: 76,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _SettingSection(
            title: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in [
                            ('system', 'System', LucideIcons.monitor),
                            ('light', 'Light', LucideIcons.sun),
                            ('dark', 'Dark', LucideIcons.moon),
                          ])
                            ChoiceChip(
                              avatar: Icon(option.$3, size: 17),
                              showCheckmark: false,
                              label: Text(option.$2),
                              selected: settings.themeMode.value == option.$1,
                              onSelected: (_) =>
                                  settings.setThemeMode(option.$1),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              _SettingRow(
                icon: LucideIcons.languages,
                title: 'Language',
                subtitle: Obx(
                  () => Text(
                    kSupportedLanguages[settings.language.value] ?? 'English',
                  ),
                ),
                onTap: () => _showLanguageDialog(settings),
              ),
            ],
          ),
          _SettingSection(
            title: 'Reminders',
            children: [
              _SettingRow(
                icon: LucideIcons.bell,
                title: 'Prayer & Azkar',
                subtitle: const Text(
                  'Prayer times · Azkar 10 min after Fajr & Maghrib',
                ),
                trailing: Obx(
                  () => Switch(
                    value: settings.notificationsEnabled.value,
                    onChanged: settings.setNotificationsEnabled,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              _SettingRow(
                icon: LucideIcons.sun,
                title: 'Daily Ayah',
                subtitle: const Text('Every day at 9:00 AM and 6:00 PM'),
                trailing: Obx(
                  () => Switch(
                    value: settings.dailyReflectionReminder.value,
                    onChanged: settings.setDailyReflectionReminder,
                  ),
                ),
              ),
            ],
          ),
          _SettingSection(
            title: 'Listening',
            children: [
              _SettingRow(
                icon: LucideIcons.cloudOff,
                title: 'Offline Mode',
                subtitle: const Text('Play only downloaded surahs'),
                trailing: Obx(
                  () => Switch(
                    value: settings.offlineMode.value,
                    onChanged: settings.setOfflineMode,
                  ),
                ),
              ),
            ],
          ),
          _SettingSection(
            title: 'Storage & privacy',
            children: [
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              _SettingRow(
                icon: LucideIcons.trash2,
                title: 'Clear All Data',
                subtitle: const Text(
                  'Clear saved preferences and local records',
                ),
                onTap: () => _confirmClearData(),
              ),
            ],
          ),
          _SettingSection(
            title: 'About',
            children: [
              _SettingRow(
                icon: LucideIcons.images,
                title: 'Photo credits & licenses',
                subtitle: const Text(
                  'Reciter portraits and open-source credits',
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'QariVerse',
                ),
              ),
              _SettingRow(
                icon: LucideIcons.handHeart,
                title: 'Contact support',
                subtitle: const Text('annurdevelopers@gmail.com'),
                onTap: () => launchUrl(
                  Uri.parse('mailto:annurdevelopers@gmail.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              _SettingRow(
                icon: LucideIcons.info,
                title: 'Version',
                subtitle: const Text('1.0.0'),
              ),
            ],
          ),
          // TEMPORARY — remove before Play Store upload. Only
          // compiled into debug builds (kDebugMode), so release
          // builds never show it.
          if (kDebugMode)
            _SettingSection(
              title: 'Developer tools',
              children: [
                _SettingRow(
                  icon: LucideIcons.volume2,
                  title: 'Test Adhan Now',
                  subtitle: const Text(
                    'Fire the prayer notification immediately',
                  ),
                  onTap: () async {
                    final diag = await NotificationService.instance
                        .debugFireAdhanNow();
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Adhan test fired'),
                        content: Text(
                          'Check the notification & listen for the '
                          'adhan.\n\n$diag',
                        ),
                        actions: [
                          TextButton(
                            onPressed: Get.back,
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

void _showLanguageDialog(SettingsController settings) {
  Get.dialog(
    AlertDialog(
      title: const Text('Choose Language'),
      content: SingleChildScrollView(
        child: RadioGroup<String>(
          groupValue: settings.language.value,
          onChanged: (v) {
            if (v != null) settings.setLanguage(v);
            Get.back();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: kSupportedLanguages.entries
                .map(
                  (e) =>
                      RadioListTile<String>(title: Text(e.value), value: e.key),
                )
                .toList(),
          ),
        ),
      ),
    ),
  );
}

void _confirmClearData() {
  Get.dialog(
    AlertDialog(
      title: const Text('Clear All Data'),
      content: const Text(
        'This clears bookmarks, notes, reading history, and settings. Downloaded audio files remain on the device; remove them from Offline first. Restart the app afterward.',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            _clearAllData();
          },
          child: const Text('Clear All', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Future<void> _clearAllData() async {
  final storage = Get.find<LocalStorageService>();
  await storage.clearAll();
  Get.snackbar(
    'Done',
    'Local records cleared. Restart the app.',
    snackPosition: SnackPosition.BOTTOM,
  );
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .25),
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final Widget subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colors.onPrimaryContainer, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.5,
            ),
            child: subtitle,
          ),
        ),
        trailing:
            trailing ??
            (onTap == null
                ? null
                : Icon(
                    LucideIcons.chevronRight,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  )),
      ),
    );
  }
}
