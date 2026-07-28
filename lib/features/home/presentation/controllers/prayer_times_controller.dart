import 'dart:async';

import 'package:adhan/adhan.dart' as adhan;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/adhan_audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class PrayerTimesController extends GetxController {
  PrayerTimesController(this._storage);

  final LocalStorageService _storage;

  final allPrayerTimes = <PrayerTimeInfo>[].obs;
  final nextPrayer = Rxn<PrayerTimeInfo>();
  final isLoading = true.obs;
  final error = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadFromCacheThenRefresh();
  }

  /// 1. If we have cached coords, compute prayer times instantly (offline-safe).
  /// 2. Then request a fresh GPS fix in the background and recompute silently.
  Future<void> _loadFromCacheThenRefresh() async {
    final cachedLat = _storage.read<double>(StorageKeys.lastLat);
    final cachedLng = _storage.read<double>(StorageKeys.lastLng);

    if (cachedLat != null && cachedLng != null) {
      _compute(cachedLat, cachedLng);
      _syncNotifications(cachedLat, cachedLng);
      isLoading(false);
      _startTimer();
      // Refresh coords silently — don't block UI.
      _refreshLocation();
    } else {
      // First launch: must wait for GPS.
      await _refreshLocation(showLoading: true);
    }
  }

  Future<void> _refreshLocation({bool showLoading = false}) async {
    if (showLoading) isLoading(true);
    error('');

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _fail(showLoading,
            'Location services are off. Turn them on for prayer times.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _fail(showLoading, 'Location permission required for prayer times');
        return;
      }

      // 1) Instant: use the OS's last known fix if there is one. This alone
      //    resolves the common "TimeoutException" on cold GPS / emulators,
      //    since a fresh fix can take far longer than any reasonable timeout.
      Position? pos = await Geolocator.getLastKnownPosition();

      // 2) Try for a fresh fix, but treat a timeout as non-fatal: if step 1
      //    gave us something we keep it; the next refresh will try again.
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 30),
          ),
        );
      } on TimeoutException {
        // Keep last-known (if any).
      }

      if (pos == null) {
        _fail(showLoading,
            "Couldn't get your location. Check GPS and try again.");
        return;
      }

      // Persist for next cold start.
      await Future.wait([
        _storage.write(StorageKeys.lastLat, pos.latitude),
        _storage.write(StorageKeys.lastLng, pos.longitude),
      ]);

      _compute(pos.latitude, pos.longitude);
      _syncNotifications(pos.latitude, pos.longitude);
      if (_timer == null || !_timer!.isActive) _startTimer();
    } catch (_) {
      _fail(showLoading, 'Failed to get location. Please try again.');
    } finally {
      if (showLoading) isLoading(false);
    }
  }

  /// Surface a location error only on the blocking first-launch path; when we
  /// already have cached prayer times, refresh failures stay silent.
  void _fail(bool showLoading, String message) {
    if (showLoading) error(message);
  }


  void _compute(double lat, double lng) {
    final coords = adhan.Coordinates(lat, lng);
    final params = adhan.CalculationMethod.muslim_world_league.getParameters()
      ..madhab = adhan.Madhab.shafi;
    final pt = adhan.PrayerTimes.today(coords, params);

    final now = DateTime.now();
    final prayers = [
      PrayerTimeInfo(name: 'Fajr',    time: pt.fajr,    isNext: false, timeRemaining: pt.fajr.difference(now)),
      PrayerTimeInfo(name: 'Sunrise', time: pt.sunrise,  isNext: false, timeRemaining: pt.sunrise.difference(now)),
      PrayerTimeInfo(name: 'Dhuhr',   time: pt.dhuhr,   isNext: false, timeRemaining: pt.dhuhr.difference(now)),
      PrayerTimeInfo(name: 'Asr',     time: pt.asr,     isNext: false, timeRemaining: pt.asr.difference(now)),
      PrayerTimeInfo(name: 'Maghrib', time: pt.maghrib, isNext: false, timeRemaining: pt.maghrib.difference(now)),
      PrayerTimeInfo(name: 'Isha',    time: pt.isha,    isNext: false, timeRemaining: pt.isha.difference(now)),
    ]..sort((a, b) => a.time.compareTo(b.time));

    PrayerTimeInfo? next;
    for (final p in prayers) {
      if (p.time.isAfter(now)) { next = p.copyWith(isNext: true); break; }
    }
    // Past all prayers today — next is tomorrow's Fajr.
    next ??= PrayerTimeInfo(
      name: 'Fajr',
      time: adhan.PrayerTimes.today(coords, params).fajr.add(const Duration(days: 1)),
      isNext: true,
      timeRemaining: adhan.PrayerTimes.today(coords, params).fajr.add(const Duration(days: 1)).difference(now),
    );

    final updated = prayers.map((p) => p.time == next!.time ? next : p).toList();
    allPrayerTimes.assignAll(updated);
    nextPrayer.value = next;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final np = nextPrayer.value;
      if (np == null) return;
      final remaining = np.time.difference(DateTime.now());
      if (remaining.isNegative) {
        final crossed = np.name;
        final lat = _storage.read<double>(StorageKeys.lastLat);
        final lng = _storage.read<double>(StorageKeys.lastLng);
        if (lat != null && lng != null) _compute(lat, lng);
        _onPrayerReached(crossed);
      } else {
        nextPrayer.update((p) => p!.timeRemaining = remaining);
      }
    });
  }

  /// Called the instant a prayer time is crossed while the app is in the
  /// foreground. Plays the full adhan — but only for the five daily prayers
  /// (Sunrise is a marker, not a prayer) and only when the user has prayer
  /// notifications enabled.
  void _onPrayerReached(String crossedName) {
    if (crossedName == 'Sunrise') return;
    if (!_notificationsEnabled) return;
    AdhanAudioService.instance.play();
  }

  /// (Re)schedule the rolling 7-day prayer notifications for [lat]/[lng],
  /// honouring the user's notification preference. Called on startup and after
  /// every fresh location fix so alerts never go stale.
  void _syncNotifications(double lat, double lng) {
    NotificationService.instance.syncPrayerSchedule(
      enabled: _notificationsEnabled,
      lat: lat,
      lng: lng,
    );
  }

  bool get _notificationsEnabled {
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    return settings?.notificationsEnabled.value ?? false;
  }

  String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> loadPrayerTimes() => _loadFromCacheThenRefresh();

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class PrayerTimeInfo {
  PrayerTimeInfo({
    required this.name,
    required this.time,
    required this.isNext,
    required this.timeRemaining,
  });

  final String name;
  final DateTime time;
  final bool isNext;
  Duration timeRemaining;

  String get formattedTime {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  PrayerTimeInfo copyWith({String? name, DateTime? time, bool? isNext, Duration? timeRemaining}) =>
      PrayerTimeInfo(
        name: name ?? this.name,
        time: time ?? this.time,
        isNext: isNext ?? this.isNext,
        timeRemaining: timeRemaining ?? this.timeRemaining,
      );
}
