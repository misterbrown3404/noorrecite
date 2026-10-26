import 'package:flutter/widgets.dart';

/// Spacing scale from DESIGN.md ("Layout & Spacing").
///
/// Base rhythm is an 8px unit with 4px micro-adjustments. Mobile keeps a 24px
/// horizontal margin so "floating" glass elements breathe against the edge.
abstract final class AppSpacing {
  /// 4px micro-adjustment unit.
  static const double unit = 4;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Standard gap between grouped elements.
  static const double gutter = 16;

  /// Horizontal safe-zone margin on mobile.
  static const double margin = 24;

  /// Internal padding for cards / glass panels.
  static const double cardPadding = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: margin,
  );
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}

/// Corner-radius scale from DESIGN.md ("Shapes").
///
/// Cards use [lg] (16px); interactive controls use [xl] (24px) or [full] pills.
abstract final class AppRadii {
  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);

  static const BorderRadius cardRadius = BorderRadius.all(rXl);
  static const BorderRadius controlRadius = BorderRadius.all(rXl);
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(full),
  );
}
