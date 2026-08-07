import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleAppointmentNotification({
    required int id,
    required String serviceName,
    required String dateStr, // Formato YYYY-MM-DD
    required String timeStr, // Formato HH:MM
  }) async {
    final parsedDateTime = DateTime.parse("$dateStr $timeStr:00");

    final notificationTime = parsedDateTime.subtract(const Duration(hours: 24));

    if (notificationTime.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'barber_channel',
      'Lembrete de Agendamento',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      "Lembrete de Agendamento 💈",
      "Seu corte está marcado para amanhã às $timeStr!",
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
