import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import 'worship_art.dart';

class AzkarCard extends StatelessWidget {
  const AzkarCard({super.key});
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFE9E0F7),
    borderRadius: BorderRadius.circular(28),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Get.toNamed(AppRoutes.azkar),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REMEMBER & RECONNECT',
              style: TextStyle(
                color: Color(0xFF70558D),
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'A quiet moment\nwith Azkar',
                    style: TextStyle(
                      color: Color(0xFF352346),
                      fontSize: 23,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                WorshipArt(azkar: true, size: 80),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Small words. A meaningful pause.',
              style: TextStyle(color: Color(0xFF70558D), fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Begin remembrance',
                    style: TextStyle(
                      color: Color(0xFF352346),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  LucideIcons.arrowRight,
                  color: Color(0xFF352346),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
