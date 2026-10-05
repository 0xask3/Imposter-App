import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract final class PrivacyScreenGuard {
  static const MethodChannel _channel = MethodChannel('imposter/privacy');
  static int _activeScreens = 0;

  static Future<void> enterSensitiveScreen() async {
    _activeScreens++;
    if (_activeScreens == 1) await _setSecure(true);
  }

  static Future<void> leaveSensitiveScreen() async {
    if (_activeScreens == 0) return;
    _activeScreens--;
    if (_activeScreens == 0) await _setSecure(false);
  }

  static Future<void> _setSecure(bool secure) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setSecure', {'enabled': secure});
    } on MissingPluginException {
      // The channel is absent in widget tests and unsupported host runners.
    } on PlatformException {
      // A platform failure must not be allowed to expose or crash the game UI.
    }
  }
}
