import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// `image_picker`'s camera capture (`ImageSource.camera`) is only implemented
/// on Android/iOS — desktop (macOS/Windows/Linux) and web throw at pick time
/// (macOS/Windows throw `StateError`, web has no camera source at all). Gate
/// any "Take a photo" / "Record a video" affordance on this so it never offers
/// a control that's guaranteed to fail.
bool get supportsCameraCapture =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
