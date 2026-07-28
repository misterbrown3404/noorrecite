import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

//import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../../core/storage/local_storage_service.dart';

/// Settings screen with profile header and app settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleLg),
        // actions: [
        //   HeaderIconAction(
        //    // icon: Icons.search,
        //    // onTap: () => Get.toNamed(AppRoutes.search),
        //   ),
        // ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingSection(
                        title: 'APPEARANCE',
                        children: [
                          _SettingRow(
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            subtitle: Obx(
                              () => Text(_themeLabel(settings.themeMode.value)),
                            ),
                            onTap: () => _showThemeDialog(settings),
                          ),
                          const Divider(
                            height: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                          ),
                          _SettingRow(
                            icon: Icons.language_outlined,
                            title: 'Language',
                            subtitle: Obx(
                              () => Text(kSupportedLanguages[settings.language.value] ?? 'English'),
                            ),
                            onTap: () => _showLanguageDialog(settings),
                          ),
                        ],
                      ),
                      _SettingSection(
                        title: 'NOTIFICATIONS',
                        children: [
                          _SettingRow(
                            icon: Icons.notifications_none_rounded,
                            title: 'Prayer Times & Reminders',
                            subtitle: const Text(
                              'Get notified for prayer times',
                            ),
                            trailing: Obx(
                              () => Switch(
                                value: settings.notificationsEnabled.value,
                                onChanged: settings.setNotificationsEnabled,
                                activeThumbColor: AppColors.primary,
                                activeTrackColor: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                          ),
                          _SettingRow(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Daily Reflection Reminder',
                            subtitle: const Text(
                              'Get a gentle nudge for your daily ayah',
                            ),
                            trailing: Obx(
                              () => Switch(
                                value: settings.dailyReflectionReminder.value,
                                onChanged: settings.setDailyReflectionReminder,
                                activeThumbColor: AppColors.tertiary,
                                activeTrackColor: AppColors.tertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _SettingSection(
                        title: 'OFFLINE',
                        children: [
                          _SettingRow(
                            icon: Icons.cloud_off_rounded,
                            title: 'Offline Mode',
                            subtitle: const Text('Play only downloaded surahs'),
                            trailing: Obx(
                              () => Switch(
                                value: settings.offlineMode.value,
                                onChanged: settings.setOfflineMode,
                                activeThumbColor: AppColors.primary,
                                activeTrackColor: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _SettingSection(
                        title: 'DATA & PRIVACY',
                        children: [
                          const Divider(
                            height: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                          ),
                          _SettingRow(
                            icon: Icons.delete_outline_rounded,
                            title: 'Clear All Data',
                            subtitle: const Text('Reset app to fresh state'),
                            onTap: () => _confirmClearData(),
                          ),
                        ],
                      ),
                      _SettingSection(
                        title: 'ABOUT',
                        children: [
                          _SettingRow(
                            icon: Icons.volunteer_activism_rounded,
                            title: 'Support This App',
                            subtitle: const Text(
                              'Free sadaqah — donate if you benefit',
                            ),
                            onTap: () => launchUrl(
                              Uri.parse('https://www.buymeacoffee.com/'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const Divider(
                            height: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                          ),
                          _SettingRow(
                            icon: Icons.info_outline_rounded,
                            title: 'Version',
                            subtitle: const Text('1.0.0'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _themeLabel(String mode) {
  switch (mode) {
    case 'light':
      return 'Light Mode';
    case 'dark':
      return 'Dark Mode';
    default:
      return 'System Default';
  }
}

void _showLanguageDialog(SettingsController settings) {
  Get.dialog(
    AlertDialog(
      title: const Text('Choose Language'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: kSupportedLanguages.entries.map((e) => RadioListTile<String>(
            title: Text(e.value),
            value: e.key,
            groupValue: settings.language.value,
            onChanged: (v) {
              if (v != null) settings.setLanguage(v);
              Get.back();
            },
          )).toList(),
        ),
      ),
    ),
  );
}

void _showThemeDialog(SettingsController settings) {
  Get.dialog(
    AlertDialog(
      title: const Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Light'),
            value: 'light',
            groupValue: settings.themeMode.value,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
              Get.back();
            },
          ),
          RadioListTile<String>(
            title: const Text('Dark'),
            value: 'dark',
            groupValue: settings.themeMode.value,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
              Get.back();
            },
          ),
          RadioListTile<String>(
            title: const Text('System Default'),
            value: 'system',
            groupValue: settings.themeMode.value,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
              Get.back();
            },
          ),
        ],
      ),
    ),
  );
}

void _confirmClearData() {
  Get.dialog(
    AlertDialog(
      title: const Text('Clear All Data'),
      content: const Text(
        'This will delete all bookmarks, downloads, statistics, and settings. This cannot be undone.',
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
    'All data cleared. Restart the app.',
    snackPosition: SnackPosition.BOTTOM,
  );
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
          ),
        ),
        ...children,
      ],
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(2, 2),
                blurRadius: 5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                offset: const Offset(-2, -2),
                blurRadius: 5,
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTypography.labelSemibold),
        subtitle: subtitle,
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                  )
                : null),
      ),
    );
  }
}
