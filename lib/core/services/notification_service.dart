import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _permissionsGranted = false;

  bool get hasPermission => _permissionsGranted;

  /// Initialize notification service and request permissions
  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("Notifications are not supported on web yet.");
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error initializing timezone: $e');
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    // Request permissions after initialization
    await requestPermissions();
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      // For Android 13+ (API 33+)
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        _permissionsGranted = status.isGranted;

        if (status.isPermanentlyDenied) {
          debugPrint('Notification permission permanently denied');
          return false;
        }
      } else {
        _permissionsGranted = await Permission.notification.isGranted;
      }

      // For iOS
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      if (result != null) {
        _permissionsGranted = result;
      }

      debugPrint('Notification permissions granted: $_permissionsGranted');
      return _permissionsGranted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check current permission status
  Future<bool> checkPermissionStatus() async {
    if (kIsWeb) return false;
    try {
      _permissionsGranted = await Permission.notification.isGranted;
      return _permissionsGranted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  /// Open app settings if permissions are denied
  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    // Check permission before scheduling
    if (!_permissionsGranted) {
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('Cannot schedule notification: Permission not granted');
        return;
      }
    }

    try {
      final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Ensure date is in the future
      if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Skip scheduling: Date $scheduledDate is in the past');
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'student_life_channel',
            'Student Life Notifications',
            channelDescription: 'Notifications for tasks and notes',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_permissionsGranted) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'student_life_channel',
          'Student Life Notifications',
          channelDescription: 'Notifications for tasks and notes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
