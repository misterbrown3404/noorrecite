/// Android accepts only one runtime permission dialog at a time.
/// Share this queue across location and notification startup flows.
class PermissionRequests {
  static Future<void> _pending = Future.value();

  static Future<T> run<T>(Future<T> Function() request) {
    final result = _pending.then((_) => request());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
