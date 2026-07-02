import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// `image_picker`'s camera capture (`ImageSource.camera`) is only implemented
/// on Android/iOS — desktop (macOS/Windows/Linux) and web throw at pick time
/// (macOS/Windows throw `StateError`, web has no camera source at all). Gate
/// any "Take a photo" / "Record a video" affordance on this so it never offers
/// a control that's guaranteed to fail.
bool get supportsCameraCapture =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Whether this build can actually complete FCM push registration. Push is
/// mobile-only today: the macOS Runner has **no `aps-environment` (Push
/// Notifications) entitlement**, so the APNS token never arrives and every
/// `getToken()` call logs "APNS token has not been set yet…" and fails. Gate
/// `NotificationService` on this so desktop never requests notification
/// permission or attempts registration it can't finish. If macOS push is ever
/// configured (entitlement + APNs key), add `Platform.isMacOS` here.
bool get supportsPushNotifications =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Apple platforms hand FCM the APNS token asynchronously after launch —
/// `getToken()` before it arrives is the "APNS token not available" failure.
/// Callers on these platforms must check `getAPNSToken()` first.
bool get requiresApnsToken => !kIsWeb && (Platform.isIOS || Platform.isMacOS);
