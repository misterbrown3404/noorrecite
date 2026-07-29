import 'package:flutter/foundation.dart';

/// Vendor-neutral crash/error sink. The app reports every uncaught error and
/// swallowed exception here instead of calling a specific SDK, so wiring in
/// Crashlytics, Sentry, or Bugsnag later is a one-line change in [instance]
/// rather than a codebase-wide edit.
///
/// The default implementation logs in debug and is silent in release. Swap it
/// once a backend is chosen:
///
/// ```dart
/// CrashReporter.instance = SentryCrashReporter();
/// ```
abstract class CrashReporter {
  static CrashReporter instance = _DebugCrashReporter();

  /// Report a non-fatal error with an optional [stack] and human [reason].
  void recordError(Object error, StackTrace? stack, {String? reason});

  /// Report a Flutter framework error (from [FlutterError.onError]).
  void recordFlutterError(FlutterErrorDetails details);

  /// Breadcrumb / log line to attach to the next report.
  void log(String message);
}

/// Default sink: prints in debug builds, no-ops in release. Guarantees the app
/// never crashes because reporting isn't configured yet.
class _DebugCrashReporter implements CrashReporter {
  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {
    if (kDebugMode) {
      debugPrint('[CrashReporter] ${reason ?? 'error'}: $error');
      if (stack != null) debugPrint(stack.toString());
    }
  }

  @override
  void recordFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
  }

  @override
  void log(String message) {
    if (kDebugMode) debugPrint('[CrashReporter] $message');
  }
}
