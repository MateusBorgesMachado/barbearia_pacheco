import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleAppointmentNotification({
    required int id,
    required String serviceName,
    required String dateStr,
    required String timeStr,
  }) async {
    final parsedDateTime = DateTime.parse("$dateStr $timeStr:00");
    final notificationTime = parsedDateTime.subtract(const Duration(hours: 24));

    if (notificationTime.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);
    final reminderLabel = serviceName.trim().isEmpty ? 'Serviço' : serviceName;

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
      "Seu horário ($reminderLabel) está marcado para amanhã às $timeStr!",
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAppointmentNotification(int id) async {
    await _notifications.cancel(id);
  }
}
