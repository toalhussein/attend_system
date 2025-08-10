import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AppSnackbars {
  // Success Snackbar
  static void showSuccessSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.success, // Use success type
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Failure Snackbar
  static void showFailureSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure, // Use failure type
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Not Available Snackbar
  static void showNotAvailableSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.help, // Use help/info type
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
