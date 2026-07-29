/// Shared duration formatting helpers, previously copy-pasted across the home
/// cards and playback UI.
abstract final class DurationFormat {
  /// `H:MM:SS` when there are hours, else `MM:SS`. Used for countdowns.
  static String hms(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// `M:SS` (or `H:MM:SS` past an hour), used for track position/elapsed labels.
  static String clock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}
