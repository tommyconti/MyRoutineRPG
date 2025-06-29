import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io';
import 'package:flutter/material.dart';

// Gestisce le notifiche motivazionali.
class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'motivational_channel',
          channelName: 'Notifiche Motivazionali',
          channelDescription: 'Ricevi notifiche motivazionali',
          defaultColor: const Color(0xFF4C1D95),
          ledColor: const Color(0xFF4C1D95),
          importance: NotificationImportance.High,
        ),
      ],
      debug: false,
    );
  }

  // Richiede i permessi su iOS.
  static Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // Programma una notifica motivazionale.
  static Future<void> scheduleMotivationalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'motivational_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  // Cancella tutte le notifiche.
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
} 