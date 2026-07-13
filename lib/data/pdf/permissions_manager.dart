import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsServices {
  const PermissionsServices();

  /// Call this before any file write operation.
  /// Returns true if permission granted (or not needed), false otherwise.
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    if (Platform.isIOS) {
      // iOS app-sandbox Documents directory doesn't need explicit permission.
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 29) {
      // Android 10+ can save app-created PDFs into public Documents through
      // MediaStore without broad external storage permission.
      return true;
    }

    var status = await Permission.storage.status;

    if (status.isGranted) return true;

    status = await Permission.storage.request();

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(context);
      }
      return false;
    }

    return status.isGranted;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الإذن مطلوب'),
        content: const Text(
          'يحتاج التطبيق إلى إذن الوصول إلى التخزين لحفظ النسخ الاحتياطية. يرجى تفعيله من إعدادات التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
}
