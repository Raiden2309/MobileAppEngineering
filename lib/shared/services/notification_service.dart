import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool _pipelineStarted = false;

  // Local notification channel engine for active foreground banners
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initial setup configuration to request permissions and capture incoming data payloads
  Future<void> setupNotificationTokenPipeline() async {
    if (_pipelineStarted) return;
    _pipelineStarted = true;

    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Request Operating System Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions.');

      // 2. Initialize Foreground local banner settings
      await _initLocalNotificationBanners();

      // 3. Capture device specific registration token
      String? token = await _fcm.getToken();

      if (token != null) {
        debugPrint("FCM Registration Token: $token");

        // Save token to your unified root users collection
        await _db.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    // 4. Token Refresh Listener
    _fcm.onTokenRefresh.listen((newToken) async {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid != null) {
        await _db.collection('users').doc(currentUid).update({
          'fcmToken': newToken,
        });
      }
    });

    // 5. Handle Foreground Messaging Events
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Received a foreground notification message: ${message.notification?.title}',
      );

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        // Force pop up a local operating system banner while app is active
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            // FIXED: Swapped CupertinoNotificationDetails for DarwinNotificationDetails
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    });
  }

  /// Configures local utility channels to bypass background restrictions when the app is active
  Future<void> _initLocalNotificationBanners() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // FIXED: Swapped CupertinoInitializationSettings for DarwinInitializationSettings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(initializationSettings);
  }
}
