import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: AppSpacing.screenPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR DAILY MOMENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A little closer,\nevery day.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 34,
            height: 1.18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Read. Reflect. Find your rhythm.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
