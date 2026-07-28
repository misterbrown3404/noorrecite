import 'package:flutter/material.dart';

/// Constrains the app to a phone-sized column on large windows.
///
/// The QariVerse UI is a mobile-only design; on desktop/web (or a resized
/// window) this centers the content at a max phone width instead of letting it
/// stretch into a wide, distorted layout. Applied once at the app root via
/// [MaterialApp.builder] so every route — including pushed ones — is framed.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.maxWidth = 430});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // On genuine phones the viewport is already narrow — no framing needed.
    if (width <= maxWidth) return child;
    return ColoredBox(
      color: const Color(0xFF0B0B0B),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          // MediaQuery is re-scoped so descendants measure the framed width,
          // not the raw window (keeps width-based layout math phone-correct).
          child: _RescopedMediaQuery(width: maxWidth, child: child),
        ),
      ),
    );
  }
}

class _RescopedMediaQuery extends StatelessWidget {
  const _RescopedMediaQuery({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(size: Size(width, data.size.height)),
      child: child,
    );
  }
}
