// lib/src/utils/auth_utils.dart
import 'package:flutter/material.dart';

class AuthUtils {
  static void showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      backgroundColor: const Color(0xff2e6f40),
      behavior: SnackBarBehavior.fixed,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20.0,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.fixed,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20.0,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String generateUserId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    String result = '#';

    for (int i = 0; i < 6; i++) {
      result += chars[random.hashCode % chars.length];
    }

    return result;
  }

  static String formatNameForFirestore(String name) {
    return name.toLowerCase().replaceAll(' ', '_');
  }
}