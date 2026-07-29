import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/reflections_controller.dart';

class AddReflectionPage extends StatefulWidget {
  const AddReflectionPage({super.key});

  @override
  State<AddReflectionPage> createState() => _AddReflectionPageState();
}

class _AddReflectionPageState extends State<AddReflectionPage> {
  final _textController = TextEditingController();
  late String _selectedAyah;
  int _selectedSurahId = 1;
  int _selectedAyahNumber = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedAyah = AppLocalizations.of(context)!.selectAyahDefault;
  }

  // Quranic ayah references for the picker (114 surahs, key ayahs)
  static final _ayahReferences = [
    (1, 1, 'Al-Fatiha 1:1'),
    (2, 255, 'Al-Baqarah 2:255 (Ayat al-Kursi)'),
    (2, 285, 'Al-Baqarah 2:285'),
    (2, 286, 'Al-Baqarah 2:286'),
    (3, 18, 'Al-Imran 3:18'),
    (4, 1, 'An-Nisa 4:1'),
    (5, 3, 'Al-Ma\'idah 5:3'),
    (6, 59, 'Al-An\'am 6:59'),
    (7, 156, 'Al-A\'raf 7:156'),
    (8, 28, 'Al-Anfal 8:28'),
    (9, 51, 'At-Tawbah 9:51'),
    (10, 62, 'Yunus 10:62'),
    (11, 88, 'Hud 11:88'),
    (12, 87, 'Yusuf 12:87'),
    (13, 28, 'Ar-Ra\'d 13:28'),
    (14, 7, 'Ibrahim 14:7'),
    (15, 9, 'Al-Hijr 15:9'),
    (16, 90, 'An-Nahl 16:90'),
    (17, 23, 'Al-Isra 17:23'),
    (18, 10, 'Al-Kahf 18:10'),
    (19, 30, 'Maryam 19:30'),
    (20, 25, 'Ta-Ha 20:25'),
    (21, 87, 'Al-Anbiya 21:87'),
    (22, 46, 'Al-Hajj 22:46'),
    (23, 1, 'Al-Mu\'minun 23:1'),
    (24, 35, 'An-Nur 24:35'),
    (25, 63, 'Al-Furqan 25:63'),
    (26, 227, 'Ash-Shu\'ara 26:227'),
    (27, 62, 'An-Naml 27:62'),
    (28, 77, 'Al-Qasas 28:77'),
    (29, 69, 'Al-Ankabut 29:69'),
    (30, 41, 'Ar-Rum 30:41'),
    (31, 12, 'Luqman 31:12'),
    (32, 16, 'As-Sajdah 32:16'),
    (33, 41, 'Al-Ahzab 33:41'),
    (34, 15, 'Saba 34:15'),
    (35, 10, 'Fatir 35:10'),
    (36, 36, 'Ya-Sin 36:36'),
    (37, 100, 'As-Saffat 37:100'),
    (38, 24, 'Sad 38:24'),
    (39, 53, 'Az-Zumar 39:53'),
    (40, 60, 'Ghafir 40:60'),
    (41, 30, 'Fussilat 41:30'),
    (42, 30, 'Ash-Shura 42:30'),
    (43, 36, 'Az-Zukhruf 43:36'),
    (44, 19, 'Ad-Dukhan 44:19'),
    (45, 23, 'Al-Jathiyah 45:23'),
    (46, 15, 'Al-Ahqaf 46:15'),
    (47, 19, 'Muhammad 47:19'),
    (48, 10, 'Al-Fath 48:10'),
    (49, 13, 'Al-Hujurat 49:13'),
    (50, 16, 'Qaf 50:16'),
    (51, 56, 'Adh-Dhariyat 51:56'),
    (52, 21, 'At-Tur 52:21'),
    (53, 23, 'An-Najm 53:23'),
    (54, 17, 'Al-Qamar 54:17'),
    (55, 13, 'Ar-Rahman 55:13'),
    (56, 77, 'Al-Waqi\'ah 56:77'),
    (57, 16, 'Al-Hadid 57:16'),
    (58, 22, 'Al-Mujadilah 58:22'),
    (59, 21, 'Al-Hashr 59:21'),
    (60, 7, 'Al-Mumtahanah 60:7'),
    (61, 2, 'As-Saff 61:2'),
    (62, 9, 'Al-Jumu\'ah 62:9'),
    (63, 9, 'Al-Munafiqun 63:9'),
    (64, 15, 'At-Taghabun 64:15'),
    (65, 2, 'At-Talaq 65:2'),
    (66, 8, 'At-Tahrim 66:8'),
    (67, 14, 'Al-Mulk 67:14'),
    (68, 4, 'Al-Qalam 68:4'),
    (69, 19, 'Al-Haqqah 69:19'),
    (70, 19, 'Al-Ma\'arij 70:19'),
    (71, 10, 'Nuh 71:10'),
    (72, 1, 'Al-Jinn 72:1'),
    (73, 20, 'Al-Muzzammil 73:20'),
    (74, 4, 'Al-Muddaththir 74:4'),
    (75, 16, 'Al-Qiyamah 75:16'),
    (76, 3, 'Al-Insan 76:3'),
    (77, 50, 'Al-Mursalat 77:50'),
    (78, 17, 'An-Naba 78:17'),
    (79, 40, 'An-Nazi\'at 79:40'),
    (80, 11, 'Abasa 80:11'),
    (81, 27, 'At-Takwir 81:27'),
    (82, 14, 'Al-Infitar 82:14'),
    (83, 22, 'Al-Mutaffifin 83:22'),
    (84, 6, 'Al-Inshiqaq 84:6'),
    (85, 20, 'Al-Buruj 85:20'),
    (86, 17, 'At-Tariq 86:17'),
    (87, 14, 'Al-A\'la 87:14'),
    (88, 17, 'Al-Ghashiyah 88:17'),
    (89, 27, 'Al-Fajr 89:27'),
    (90, 17, 'Al-Balad 90:17'),
    (91, 7, 'Ash-Shams 91:7'),
    (92, 18, 'Al-Layl 92:18'),
    (93, 4, 'Ad-Duha 93:4'),
    (94, 5, 'Ash-Sharh 94:5'),
    (95, 8, 'At-Tin 95:8'),
    (96, 1, 'Al-Alaq 96:1'),
    (97, 3, 'Al-Qadr 97:3'),
    (98, 5, 'Al-Bayyinah 98:5'),
    (99, 7, 'Az-Zalzalah 99:7'),
    (100, 8, 'Al-Adiyat 100:8'),
    (101, 6, 'Al-Qari\'ah 101:6'),
    (102, 8, 'At-Takathur 102:8'),
    (103, 3, 'Al-Asr 103:3'),
    (104, 9, 'Al-Humazah 104:9'),
    (105, 3, 'Al-Fil 105:3'),
    (106, 3, 'Quraysh 106:3'),
    (107, 7, 'Al-Ma\'un 107:7'),
    (108, 1, 'Al-Kawthar 108:1'),
    (109, 6, 'Al-Kafirun 109:6'),
    (110, 3, 'An-Nasr 110:3'),
    (111, 1, 'Al-Masad 111:1'),
    (112, 1, 'Al-Ikhlas 112:1'),
    (113, 1, 'Al-Falaq 113:1'),
    (114, 1, 'An-Nas 114:1'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reflection'),
        
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppHeader(onMenu: Get.back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.selectAyah,
                                style: AppTypography.labelCaps,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              PressableScale(
                                onTap: _showAyahPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: AppRadii.cardRadius,
                                    border: Border.all(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          _selectedAyah,
                                          style: AppTypography.labelSemibold,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.tertiary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    l10n.yourReflection,
                                    style: AppTypography.labelCaps.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: AppRadii.cardRadius,
                                  boxShadow: AppShadows.inset,
                                ),
                                child: TextField(
                                  controller: _textController,
                                  maxLines: 8,
                                  minLines: 6,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: l10n.reflectionHint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                l10n.cancel,
                                style: AppTypography.labelSemibold.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            GlowPrimaryButton(
                              label: l10n.saveReflection,
                              trailingIcon: Icons.check_circle_outline,
                              expand: false,
                              height: 44,
                              onPressed: _saveReflection,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAyahPicker() {
    final l10n = AppLocalizations.of(context)!;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.selectAyahSheet, style: AppTypography.titleLg),
            const SizedBox(height: AppSpacing.md),
            ..._ayahReferences.map(
              (ref) => ListTile(
                title: Text(ref.$3, style: AppTypography.bodyEn),
                onTap: () {
                  setState(() {
                    _selectedSurahId = ref.$1;
                    _selectedAyahNumber = ref.$2;
                    _selectedAyah = ref.$3;
                  });
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _saveReflection() {
    final l10n = AppLocalizations.of(context)!;
    if (_textController.text.trim().isEmpty) {
      Get.snackbar(
        l10n.empty,
        l10n.pleaseWriteReflection,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppSpacing.md),
      );
      return;
    }

    Get.find<ReflectionsController>().save(
          surahId: _selectedSurahId,
          ayahNumber: _selectedAyahNumber,
          reference: _selectedAyah,
          note: _textController.text.trim(),
          savedAtMs: DateTime.now().millisecondsSinceEpoch,
        );

    Get.snackbar(
      l10n.saved,
      l10n.reflectionHasSaved,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSpacing.md),
    );
    Get.back();
  }
}
