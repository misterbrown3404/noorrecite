import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Home screen greeting line.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Assalamu Alaikum,', style: AppTypography.titleLg)],
      ),
    );
  }
}
