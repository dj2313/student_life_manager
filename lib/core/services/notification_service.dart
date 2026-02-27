import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _permissionsGranted = false;

  bool get hasPermission => _permissionsGranted;

  /// Initialize notification service and request permissions
  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("Notifications are not supported on web yet.");
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

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

    // Dynamic Timezone detection
    try {
      tz.initializeTimeZones();
      final dynamic result = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = result.toString();

      // Normalization: Handle common variations or legacy names
      if (timeZoneName == 'Asia/Calcutta') timeZoneName = 'Asia/Kolkata';

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('Timezone successfully set to: $timeZoneName');
      } catch (e) {
        debugPrint(
          'Timezone "$timeZoneName" not found in DB, falling back to IST (Asia/Kolkata)',
        );
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }
    } catch (e) {
      debugPrint('Critical error in timezone initialization: $e');
      // Final safety net fallbacks
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        debugPrint('Defaulted to Asia/Kolkata after failure');
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint('Defaulted to UTC after double failure');
      }
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    // Request permissions after initialization
    await requestPermissions();

    // Setup FCM
    await _setupFCM();
  }

  Future<void> _setupFCM() async {
    if (kIsWeb) return;

    // Get the FCM token
    String? token = await _fcm.getToken();
    debugPrint("FCM Token: $token");

    // Save token to Firestore if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    // Foreground listening
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        "FCM Message Received in Foreground: ${message.notification?.title}",
      );
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? "New Notification",
          body: message.notification!.body ?? "",
        );
      }
    });

    // Background/Terminated click handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("FCM Message clicked: ${message.data}");
      // Navigate to specific screen based on data here
    });
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
        }
      } else {
        _permissionsGranted = await Permission.notification.isGranted;
      }

      // Check for Exact Alarm permission (Android 12+)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final status = await Permission.scheduleExactAlarm.status;
          if (status.isDenied || status.isPermanentlyDenied) {
            debugPrint('Note: Exact alarm permission not granted.');
            await Permission.scheduleExactAlarm.request();
          }

          // Request ignoring battery optimizations for reliability
          if (await Permission.ignoreBatteryOptimizations.isDenied) {
            debugPrint('Requesting ignore battery optimizations...');
            await Permission.ignoreBatteryOptimizations.request();
          }
        } catch (e) {
          debugPrint('Exact alarm / battery optimize check error: $e');
        }
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

    // Truncate ID to 32-bit integer to prevent Android crashes
    final safeId = id.toSigned(31);

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

      // Ensure date is in the future.
      final now = tz.TZDateTime.now(tz.local);

      // Audit Debug Prints
      debugPrint("Scheduling notification for: $scheduledDate");
      debugPrint("Is future? ${scheduledTZDate.isAfter(now)}");
      debugPrint("Current Local Time: $now");
      debugPrint("Scheduled TZ Time: $scheduledTZDate");

      if (scheduledTZDate.isBefore(now)) {
        debugPrint(
          'Skip scheduling: Date $scheduledDate is in the past (Current: $now)',
        );
        return;
      }

      debugPrint('Scheduling notification $safeId for $scheduledTZDate');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        safeId,
        title,
        body,
        scheduledTZDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'student_life_channel',
            'Student Life Notifications',
            channelDescription: 'Notifications for tasks and notes',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            showWhen: true,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Notification $safeId scheduled successfully.');
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

  /// Schedule daily German Vocabulary reminder at 6:30 PM (18:30) IST
  Future<void> scheduleDailyGermanVocab() async {
    if (kIsWeb) return;

    // Check permission before scheduling
    if (!_permissionsGranted) {
      await requestPermissions();
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        18, // 6 PM
        30, // 30 minutes
      );

      // If it's already past 6:30 PM today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        999, // Use a unique ID for this daily notification
        '🇩🇪 German Vocab Time!',
        'Time to master some new words! Open your Lexicon and practice.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'german_vocab_channel',
            'German Language Prep',
            channelDescription: 'Daily reminders for German learning',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        'Scheduled Daily German Vocab at: ${scheduledDate.toString()}',
      );
    } catch (e) {
      debugPrint('Error scheduling daily German vocab: $e');
    }
  }
}
