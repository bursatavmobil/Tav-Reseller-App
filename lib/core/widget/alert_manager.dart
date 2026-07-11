import 'package:flutter/material.dart';
import 'package:reseller_app_tav/core/widget/cutsom_alert_widget.dart';

class AlertManager {
  static void show(BuildContext context, String message, bool isSuccess) {
    CustomAnimatedAlert.show(context, message, isSuccess);
  }

  static void showError(BuildContext context, dynamic error) {
    final cleanMessage = error.toString().replaceAll('Exception: ', '');
    CustomAnimatedAlert.show(
      context,
      cleanMessage.isNotEmpty ? cleanMessage : "Terjadi kesalahan.",
      false,
    );
  }
}
