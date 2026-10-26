import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qari_verse/core/storage/local_storage_service.dart';
import 'package:qari_verse/core/storage/storage_keys.dart';
import 'package:qari_verse/features/home/presentation/controllers/prayer_times_controller.dart';

class _Storage implements LocalStorageService {
  final values = <String, Object?>{};
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  Future<void> write(String key, Object? value) async {
    values[key] = value;
  }

  @override
  Map<String, dynamic>? readJson(String key) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Location extends PrayerLocationSource {
  bool serviceEnabled = true;
  LocationPermission access = LocationPermission.whileInUse;
  bool timeout = false;
  int requests = 0;
  final position = Position(
    longitude: 3.3792,
    latitude: 6.5244,
    timestamp: DateTime(2026),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  @override
  Future<bool> enabled() async => serviceEnabled;
  @override
  Future<LocationPermission> permission() async => access;
  @override
  Future<LocationPermission> request() async {
    requests++;
    return access;
  }

  @override
  Future<Position?> lastKnown() async => timeout ? position : null;
  @override
  Future<Position> current() async {
    if (timeout) throw TimeoutException('GPS');
    return position;
  }

  @override
  Future<String?> place(double lat, double lng) async => 'Lagos';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('fresh location is saved and prayer schedule is ready', () async {
    final storage = _Storage();
    final location = _Location();
    var syncs = 0;
    final controller = PrayerTimesController(
      storage,
      location: location,
      syncReminders: (_, _) async {
        syncs++;
      },
    );
    await controller.loadPrayerTimes();
    expect(controller.error.value, isEmpty);
    expect(controller.locationLabel.value, 'Lagos');
    expect(controller.allPrayerTimes.length, 6);
    expect(storage.read<double>(StorageKeys.lastLat), 6.5244);
    expect(syncs, 1);
    controller.onClose();
  });
  test('disabled GPS keeps cached times and exposes recovery action', () async {
    final storage = _Storage()
      ..values.addAll({
        StorageKeys.lastLat: 6.5244,
        StorageKeys.lastLng: 3.3792,
      });
    final location = _Location()..serviceEnabled = false;
    final controller = PrayerTimesController(
      storage,
      location: location,
      syncReminders: (_, _) async {},
    );
    await controller.loadPrayerTimes();
    expect(controller.error.value, isEmpty);
    expect(controller.nextPrayer.value, isNotNull);
    expect(controller.locationMessage.value, contains('Using saved location'));
    expect(controller.locationAction.value, 'location');
    controller.onClose();
  });
  test(
    'permanently denied permission directs user to settings without prompting',
    () async {
      final location = _Location()..access = LocationPermission.deniedForever;
      final controller = PrayerTimesController(
        _Storage(),
        location: location,
        syncReminders: (_, _) async {},
      );
      await controller.loadPrayerTimes();
      expect(location.requests, 0);
      expect(controller.locationAction.value, 'app');
      expect(controller.error.value, contains('blocked'));
      expect(controller.isLoading.value, isFalse);
      controller.onClose();
    },
  );
  test('GPS timeout falls back to device last known location', () async {
    final controller = PrayerTimesController(
      _Storage(),
      location: _Location()..timeout = true,
      syncReminders: (_, _) async {},
    );
    await controller.loadPrayerTimes();
    expect(controller.nextPrayer.value, isNotNull);
    expect(controller.locationMessage.value, contains('last known'));
    controller.onClose();
  });
}
