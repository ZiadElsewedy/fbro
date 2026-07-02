import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global debug logging for DROP. Colour-coded, zero-cost in release builds
/// (every method no-ops unless [enabled]).
///
/// Conventions:
/// - **yellow** — a function/flow was entered ([call], and the start line of
///   [time]);
/// - **green** — it finished successfully ([success], [time]'s end line);
/// - **red** — it failed ([error]);
/// - **cyan** — navigation ([route]) and cubit state changes.
///
/// ANSI colours render in `flutter run` terminals and VS Code's debug console;
/// on consoles that strip ANSI (Xcode) the text degrades to plain lines.
class AppLog {
  AppLog._();

  /// Master switch — debug builds only by default. Flip off for a quiet run.
  static bool enabled = kDebugMode;

  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _cyan = '\x1B[36m';
  static const _reset = '\x1B[0m';

  static String _stamp() {
    final n = DateTime.now();
    String p(int v, [int w = 2]) => v.toString().padLeft(w, '0');
    return '${p(n.hour)}:${p(n.minute)}:${p(n.second)}.${p(n.millisecond, 3)}';
  }

  static void _print(String color, String scope, String message) {
    if (!enabled) return;
    debugPrint('$color[${_stamp()}][$scope] $message$_reset');
  }

  /// Yellow — a function/flow was entered.
  static void call(String scope, String fn, [String? details]) =>
      _print(_yellow, scope, '→ $fn${details == null ? '' : ' ($details)'}');

  /// Green — an operation completed.
  static void success(String scope, String message) =>
      _print(_green, scope, '✓ $message');

  /// Red — an operation failed.
  static void error(String scope, String message,
      [Object? err, StackTrace? stack]) {
    _print(_red, scope, '✗ $message${err == null ? '' : ' — $err'}');
    if (stack != null && enabled) debugPrint('$_red$stack$_reset');
  }

  /// Cyan — navigation events (route pushes/pops, redirect decisions).
  static void route(String message) => _print(_cyan, 'nav', message);

  /// Times an async [operation]: yellow on entry, green with the elapsed
  /// milliseconds on completion, red (and rethrow) on failure.
  static Future<T> time<T>(
    String scope,
    String label,
    Future<T> Function() operation,
  ) async {
    call(scope, label);
    final sw = Stopwatch()..start();
    try {
      final result = await operation();
      success(scope, '$label (${sw.elapsedMilliseconds}ms)');
      return result;
    } catch (e) {
      error(scope, '$label failed after ${sw.elapsedMilliseconds}ms', e);
      rethrow;
    }
  }
}

/// Cubit lifecycle logging for every cubit in the app — wire once in `main`:
/// `Bloc.observer = AppBlocObserver();`. Create/close are yellow flow marks,
/// state changes are cyan (state runtimeType only — never payloads, which can
/// carry PII and flood the console), errors are red.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLog.call('cubit', '${bloc.runtimeType} created');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (AppLog.enabled) {
      AppLog.route(
          '${bloc.runtimeType}: ${change.currentState.runtimeType} → '
          '${change.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLog.error('cubit', '${bloc.runtimeType} threw', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLog.call('cubit', '${bloc.runtimeType} closed');
  }
}

/// Route logging for a [Navigator] — attach to GoRouter's `observers` (root
/// navigator) AND the ShellRoute's `observers` (the shell navigator, where all
/// in-shell page swaps happen).
class LoggingNavigatorObserver extends NavigatorObserver {
  LoggingNavigatorObserver(this.label);

  /// Which navigator this observer watches (e.g. `root`, `shell`).
  final String label;

  String _name(Route<dynamic>? route) =>
      route?.settings.name ??
      route?.settings.runtimeType.toString() ??
      'unknown';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AppLog.route('[$label] push ${_name(route)} (from ${_name(previousRoute)})');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AppLog.route('[$label] pop ${_name(route)} (to ${_name(previousRoute)})');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      AppLog.route('[$label] replace ${_name(oldRoute)} → ${_name(newRoute)}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AppLog.route('[$label] remove ${_name(route)}');
}
