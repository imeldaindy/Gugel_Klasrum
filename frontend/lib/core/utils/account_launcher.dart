import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka halaman akun Google / pengaturan akun perangkat.
class AccountLauncher {
  /// Buka myaccount.google.com untuk akun [email] (browser / app Google).
  static Future<bool> openGoogleAccount(String email) async {
    final uri = Uri.https('myaccount.google.com', '/', {'authuser': email});
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Pengaturan "Akun" di perangkat Android (kelola akun di perangkat ini).
  static Future<bool> openDeviceAccounts() async {
    if (!_isAndroid) return false;
    try {
      await const AndroidIntent(action: 'android.settings.SYNC_SETTINGS')
          .launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Layar tambah akun bawaan Android.
  static Future<bool> openAddDeviceAccount() async {
    if (!_isAndroid) return false;
    try {
      await const AndroidIntent(
        action: 'android.settings.ADD_ACCOUNT_SETTINGS',
      ).launch();
      return true;
    } catch (_) {
      return false;
    }
  }
}
