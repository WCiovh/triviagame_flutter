import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> requestPermissionAndSchedule() async {
    final bool granted;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? true;
    } else if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } else {
      return;
    }

    if (granted) {
      await _scheduleWeeklyReminder();
    }
  }

  static Future<void> _scheduleWeeklyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'weekly_reminder',
      'Cotygodniowe przypomnienia',
      channelDescription: 'Przypomnienia zachęcające do gry w trivia',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      1,
      'Czas na trivia! 🎮',
      'Zagraj rundę z przyjaciółmi i sprawdź kto jest najlepszy!',
      _nextDailyAt18(),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextDailyAt18() {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, 18);

    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(candidate.toUtc(), tz.UTC);
  }
}
