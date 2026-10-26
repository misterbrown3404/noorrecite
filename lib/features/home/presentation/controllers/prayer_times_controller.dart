import '../../../../core/services/permission_requests.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/services/adhan_audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/prayer_schedule.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
export '../../../../core/services/prayer_schedule.dart' show PrayerTimeInfo;

/// Injectable platform boundary for location failure/permission tests.
class PrayerLocationSource {
  Future<bool> enabled() => Geolocator.isLocationServiceEnabled();
  Future<LocationPermission> permission() => Geolocator.checkPermission();
  Future<LocationPermission> request() =>
      PermissionRequests.run(Geolocator.requestPermission);
  Future<Position?> lastKnown() => Geolocator.getLastKnownPosition();
  Future<Position> current() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 30),
    ),
  );
  Future<String?> place(double lat, double lng) async {
    final places = await placemarkFromCoordinates(
      lat,
      lng,
    ).timeout(const Duration(seconds: 5));
    if (places.isEmpty) return null;
    final p = places.first;
    final parts = [
      p.locality,
      p.administrativeArea,
    ].whereType<String>().where((s) => s.isNotEmpty).toSet();
    return parts.isEmpty ? null : parts.join(', ');
  }
}

class PrayerTimesController extends GetxController with WidgetsBindingObserver {
  PrayerTimesController(
    this._storage, {
    PrayerLocationSource? location,
    this.syncReminders,
  }) : _location = location ?? PrayerLocationSource();
  final LocalStorageService _storage;
  final PrayerLocationSource _location;
  final Future<void> Function(double, double)? syncReminders;
  final allPrayerTimes = <PrayerTimeInfo>[].obs;
  final nextPrayer = Rxn<PrayerTimeInfo>();
  final currentPrayer = Rxn<PrayerTimeInfo>();
  final afterSunrise = false.obs;
  final hijriDate = ''.obs;
  DateTime? _refreshAt;
  final remaining = Duration.zero.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;
  final locationLabel = 'Your prayer location'.obs;
  final locationMessage = 'Finding your location…'.obs;
  final locationAction = ''.obs;
  Timer? _timer;
  Future<void>? _refresh;
  DateTime? _calculatedDate;
  bool _foreground = true;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadPrayerTimes());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _recomputeFromCache();
      unawaited(_load(requestPermission: false));
    }
  }

  bool _recomputeFromCache() {
    final lat = _storage.read<double>(StorageKeys.lastLat);
    final lng = _storage.read<double>(StorageKeys.lastLng);
    if (lat == null || lng == null) return false;
    _compute(lat, lng);
    if (locationLabel.value == 'Your prayer location') {
      locationLabel('${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}');
    }
    return true;
  }

  Future<void> loadPrayerTimes() => _load(requestPermission: true);
  Future<void> _load({required bool requestPermission}) {
    return _refresh ??= _refreshLocation(
      requestPermission: requestPermission,
    ).whenComplete(() => _refresh = null);
  }

  Future<void> _refreshLocation({required bool requestPermission}) async {
    final cached = _recomputeFromCache();
    isLoading(!cached);
    isRefreshing(true);
    error('');
    locationAction('');
    locationMessage(
      cached ? 'Using saved location · updating…' : 'Finding your location…',
    );
    if (cached) _startTimer();
    try {
      if (!await _location.enabled()) {
        locationAction('location');
        throw StateError(
          'Location services are off. Turn them on to update your prayer times.',
        );
      }
      var permission = await _location.permission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await _location.request();
      }
      if (permission == LocationPermission.deniedForever) {
        locationAction('app');
        throw StateError(
          'Location access is blocked. Enable it in app settings.',
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw StateError(
          'Location permission is needed to calculate your local prayer times.',
        );
      }
      Position? position;
      try {
        position = await _location.lastKnown();
      } catch (_) {
        /* A fresh fix can still succeed. */
      }
      var fresh = true;
      try {
        position = await _location.current();
      } catch (_) {
        fresh = false;
      }
      if (position == null) {
        throw StateError(
          'Couldn’t get your location. Check GPS and try again.',
        );
      }
      await Future.wait([
        _storage.write(StorageKeys.lastLat, position.latitude),
        _storage.write(StorageKeys.lastLng, position.longitude),
      ]);
      if (isClosed) return;
      _compute(position.latitude, position.longitude);
      _startTimer();
      locationLabel(
        '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
      );
      locationMessage(
        fresh
            ? 'Updated from your device location'
            : 'Using the device’s last known location',
      );
      await _sync(position.latitude, position.longitude);
      try {
        final place = await _location.place(
          position.latitude,
          position.longitude,
        );
        if (!isClosed && place != null) locationLabel(place);
      } catch (_) {
        /* Coordinates remain available offline. */
      }
    } catch (e) {
      if (isClosed) return;
      final message = e is StateError
          ? e.message.toString()
          : 'Couldn’t update location. Please try again.';
      locationMessage(cached ? '$message Using saved location.' : message);
      if (!cached) error(message);
      if (cached) {
        await _sync(
          _storage.read<double>(StorageKeys.lastLat)!,
          _storage.read<double>(StorageKeys.lastLng)!,
        );
      }
    } finally {
      if (!isClosed) {
        isLoading(false);
        isRefreshing(false);
      }
    }
  }

  void _compute(double lat, double lng) {
    final now = DateTime.now();
    final schedule = PrayerSchedule.at(lat, lng, now);
    allPrayerTimes.assignAll(schedule.today);
    nextPrayer.value = schedule.next;
    currentPrayer.value = schedule.current;
    afterSunrise.value = schedule.afterSunrise;
    hijriDate.value = schedule.hijriDate;
    _refreshAt = schedule.refreshAt;
    remaining.value = schedule.next.time.difference(now);
    _calculatedDate = DateTime(now.year, now.month, now.day);
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final previous = nextPrayer.value;
      if (previous == null) return;
      final due = !previous.time.isAfter(now);
      if (due ||
          (_refreshAt != null && !now.isBefore(_refreshAt!)) ||
          _calculatedDate != DateTime(now.year, now.month, now.day)) {
        _recomputeFromCache();
        if (due &&
            _foreground &&
            defaultTargetPlatform != TargetPlatform.android &&
            _notificationsEnabled &&
            PrayerSchedule.shouldAnnounce(previous, now)) {
          unawaited(AdhanAudioService.instance.play());
        }
      } else {
        remaining.value = previous.time.difference(now);
      }
    });
  }

  Future<void> _sync(double lat, double lng) async {
    try {
      if (syncReminders != null) {
        await syncReminders!(lat, lng);
        return;
      }
      await NotificationService.instance.syncPrayerSchedule(
        enabled: _notificationsEnabled,
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      /* NotificationService exposes its error in reminder status. */
    }
  }

  bool get _notificationsEnabled => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>().notificationsEnabled.value
      : (_storage.readJson(StorageKeys.settings)?['notificationsEnabled']
                as bool?) ??
            true;

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }
}
