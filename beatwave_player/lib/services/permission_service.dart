import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses granular media permissions
      final androidInfo = await _getAndroidSdkVersion();
      if (androidInfo >= 33) {
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for local audio
      return true;
    }
    return false;
  }

  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidSdkVersion();
      if (androidInfo >= 33) {
        return await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<int> _getAndroidSdkVersion() async {
    try {
      // permission_handler handles this internally, but for explicit checks:
      if (await Permission.audio.status != PermissionStatus.permanentlyDenied) {
        // Try to detect Android version by attempting audio permission
        return 33; // Assume 33+ if audio permission is available
      }
    } catch (_) {}
    return 32;
  }
}
