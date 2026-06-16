import Flutter
import UIKit

// MARK: - Firebase Phone Authentication (silent APNs push) — iOS setup
//
// Firebase Phone Auth verifies that each OTP request comes from THIS app by
// sending a *silent* APNs push notification to the device before the SMS is
// dispatched. For that silent push to be delivered, three things must be in
// place, and all three are now configured in this project:
//
//   1. Push Notifications capability  -> ios/Runner/Runner.entitlements
//                                         (aps-environment) + CODE_SIGN_ENTITLEMENTS.
//   2. Background Modes / remote-notification -> ios/Runner/Info.plist
//                                         (UIBackgroundModes).
//   3. An APNs Authentication Key uploaded to the Firebase console
//      (Project settings > Cloud Messaging) for this app's bundle id. ← console step.
//
// Forwarding of the APNs device token and the silent notification to
// FirebaseAuth's `setAPNSToken(_:type:)` / `canHandleNotification(_:)` is done
// automatically by Firebase's UIApplicationDelegate **method swizzling**, which
// is ENABLED by default (we intentionally do NOT set
// `FirebaseAppDelegateProxyEnabled = NO` in Info.plist). This is Firebase's
// recommended setup and is required for `firebase_messaging` to keep receiving
// its token without manual forwarding. The warning
// "remote notifications received by UIApplicationDelegate need to be forwarded
// to FirebaseAuth's canHandleNotification" appears only when that silent push
// never arrives — i.e. when the capabilities above are missing — not because
// forwarding code is absent. With swizzling on, manually overriding the
// notification callbacks here would double-handle the push, so we leave them to
// Firebase.

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
