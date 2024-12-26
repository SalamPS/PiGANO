import 'package:flutter/material.dart';

class NotificationUtils {
  static void showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message, 
                style: const TextStyle(color: Colors.black87),
              )
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 230, 250, 252),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showErrorNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message, 
                style: const TextStyle(color: Colors.black87),
              )
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 248, 181, 198),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 