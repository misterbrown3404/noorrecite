/// Wraps a cached JSON payload with the wall-clock time it was written, so
/// callers can decide whether a background refresh is worthwhile (TTL) while
/// still serving the stored copy instantly.
///
/// Persisted shape: `{ "v": 1, "ts": <epochMs>, "data": <List|Map> }`.
class CacheEnvelope<T> {
  const CacheEnvelope({required this.data, required this.savedAtMs});

  final T data;
  final int savedAtMs;

  /// Age of the cached copy relative to [now] (defaults to wall clock).
  Duration age([DateTime? now]) => (now ?? DateTime.now()).difference(
    DateTime.fromMillisecondsSinceEpoch(savedAtMs),
  );

  /// True when the cache is older than [ttl] and a refresh is warranted.
  bool isStale(Duration ttl, [DateTime? now]) => age(now) > ttl;

  Map<String, dynamic> toJson() => {'v': 1, 'ts': savedAtMs, 'data': data};

  /// Parses a stored envelope, returning `null` when the shape is unexpected
  /// (older/corrupt writes) so callers fall back to a network fetch.
  static CacheEnvelope<D>? tryParse<D>(Map<String, dynamic>? json) {
    if (json == null) return null;
    final ts = json['ts'];
    final data = json['data'];
    if (ts is! int || data is! D) return null;
    return CacheEnvelope<D>(data: data, savedAtMs: ts);
  }
}
