import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/services/permission_requests.dart';

void main() {
  test(
    'permission requests run sequentially and recover after a failure',
    () async {
      final gate = Completer<void>();
      final calls = <int>[];
      final first = PermissionRequests.run(() async {
        calls.add(1);
        await gate.future;
      });
      final second = PermissionRequests.run(() async {
        calls.add(2);
        throw StateError('denied');
      });
      final checked = expectLater(second, throwsStateError);
      final third = PermissionRequests.run(() async {
        calls.add(3);
        return true;
      });
      await Future<void>.delayed(Duration.zero);
      expect(calls, [1]);
      gate.complete();
      await first;
      await checked;
      expect(await third, isTrue);
      expect(calls, [1, 2, 3]);
    },
  );
}
