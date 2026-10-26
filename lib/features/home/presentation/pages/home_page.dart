import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../reading_progress/presentation/reading_journey_card.dart';
import '../controllers/prayer_times_controller.dart';
import '../widgets/continue_listening_card.dart';
import '../widgets/home_shortcuts.dart';
import '../widgets/daily_ayah_card.dart';
import '../widgets/next_prayer_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, d MMM',
                                Localizations.localeOf(context).languageCode,
                              ).format(DateTime.now()).toUpperCase(),
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Assalamu Alaikum',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Settings',
                        onPressed: () => Get.toNamed(AppRoutes.settings),
                        icon: const Icon(
                          LucideIcons.settings,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    offset: 14,
                    child: NextPrayerCard(
                      controller: Get.find<PrayerTimesController>(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const HomeShortcuts(),
                  const SizedBox(height: 24),
                  const DailyAyahCard(),
                  const SizedBox(height: 24),
                  const ReadingJourneyCard(compact: true),
                  const SizedBox(height: 20),
                  const ContinueListeningCard(),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 210)),
          ],
        ),
      ),
    );
  }
}
