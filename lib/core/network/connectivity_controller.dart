import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../error/crash_reporter.dart';
import '../../features/quran_reader/presentation/controllers/surah_controller.dart';
import '../../features/reciters/presentation/controllers/reciter_controller.dart';

/// App-wide network reachability, wrapping `connectivity_plus`.
///
/// Exposes a reactive [isOnline] flag (consumed by the global offline banner)
/// and, on every offline→online transition, silently re-fetches the
/// network-backed screens that failed while disconnected — so the user doesn't
/// have to hunt for a "Retry" button once signal returns.
///
/// Caveat: `connectivity_plus` reports the active network *interface*
/// (wifi/mobile/none), not true internet reachability. A captive portal or a
/// dead uplink can still read as "online". That's an acceptable signal for a
/// banner + opportunistic retry; the Dio layer remains the source of truth for
/// actual request success (it surfaces a Failure the user can retry manually).
class ConnectivityController extends GetxController {
  ConnectivityController([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Whether any network interface is currently active. Starts optimistically
  /// `true` so the banner never flashes before the first probe resolves.
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _probeInitial();
    _sub = _connectivity.onConnectivityChanged.listen(
      _handleResults,
      onError: (Object e, StackTrace s) => CrashReporter.instance.recordError(
        e,
        s,
        reason: 'connectivity stream',
      ),
    );
  }

  Future<void> _probeInitial() async {
    try {
      _handleResults(await _connectivity.checkConnectivity());
    } catch (e, s) {
      CrashReporter.instance.recordError(
        e,
        s,
        reason: 'connectivity initial probe',
      );
    }
  }

  void _handleResults(List<ConnectivityResult> results) {
    final online =
        results.any((r) => r != ConnectivityResult.none) && results.isNotEmpty;
    final wasOffline = !isOnline.value;
    isOnline.value = online;
    // Only act on the rising edge (offline→online), not every wifi/mobile flip.
    if (online && wasOffline) _retryFailedFetches();
  }

  /// Re-fetch the network-backed controllers that are currently in a failed or
  /// empty state. Guarded by [Get.isRegistered] because screen-scoped
  /// controllers (e.g. [SurahController]) only exist while their route is live.
  void _retryFailedFetches() {
    if (Get.isRegistered<ReciterController>()) {
      final rc = Get.find<ReciterController>();
      if (rc.error.isNotEmpty || rc.reciters.isEmpty) rc.fetchReciters();
    }
    if (Get.isRegistered<SurahController>()) {
      final sc = Get.find<SurahController>();
      if (sc.error.isNotEmpty || sc.suwar.isEmpty) sc.fetchSuwar();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
