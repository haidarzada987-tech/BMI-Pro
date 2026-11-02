import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the once-a-week weigh-in reminder (Fridays, 09:00 local).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Keep the package default location if the platform lookup fails.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin
        .initialize(const InitializationSettings(android: android));
  }

  /// Next Friday at 09:00 local time (today counts if it is still ahead).
  static tz.TZDateTime _nextFridayNine() {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    while (when.weekday != DateTime.friday || !when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    return when;
  }

  static Future<void> setWeeklyReminder(
    bool enabled, {
    required String title,
    required String body,
  }) async {
    try {
      if (!enabled) {
        await _plugin.cancel(_reminderId);
        return;
      }
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_weight_reminder',
          'Weekly weight reminder',
          channelDescription: 'Reminds you to log your weight once a week',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );
      await _plugin.zonedSchedule(
        _reminderId,
        title,
        body,
        _nextFridayNine(),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (_) {
      // A reminder problem must never crash the app.
    }
  }
}
