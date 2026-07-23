/// Build-time configuration for the external NestJS API (chat backend).
///
/// The base URL is a compile-time constant so it can never drift at runtime and
/// carries no secret — override it per environment with a dart-define. The same
/// value is used for both REST and the Socket.IO namespace, so one define wires
/// the whole chat backend:
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.dropshop.example
/// ```
///
/// Defaults to `localhost` (works for the **iOS Simulator**, which shares the
/// host's loopback). For **physical devices** — and to run the iOS Simulator
/// and an Android phone against the *same* dev backend — pass the Mac's LAN IP,
/// e.g. `--dart-define=API_BASE_URL=http://192.168.1.8:3000`, and start the
/// backend bound to `0.0.0.0`. (An **Android emulator** alternatively reaches
/// the host at `http://10.0.2.2:3000`.) `localhost` never works from a physical
/// Android device — it resolves to the phone itself.
class NetworkConfig {
  NetworkConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// One ceiling for connect / send / receive — the API is a small internal
  /// service; anything slower than this is down, not slow.
  static const Duration timeout = Duration(seconds: 20);
}
