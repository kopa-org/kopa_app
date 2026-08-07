import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/push_notifications_repository.dart';
import 'package:kopa/services/secure_storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'kopa_general_notifications',
    'Kopa Notifications',
    description: 'General notifications for Kopa updates.',
    importance: Importance.high,
  );

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final PushNotificationsRepository _repository = PushNotificationsRepository();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  bool _initialized = false;
  Future<void>? _syncInFlight;
  void Function(Map<String, dynamic> data)? _notificationTapHandler;
  Map<String, dynamic>? _pendingNotificationTap;

  void setNotificationTapHandler(void Function(Map<String, dynamic>) handler) {
    _notificationTapHandler = handler;
    final pendingData = _pendingNotificationTap;
    _pendingNotificationTap = null;
    if (pendingData != null) handler(pendingData);
  }

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      _initialized = true;
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _configureForegroundPresentation();
    await _handleInitialMessage();

    _foregroundMessageSubscription ??=
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _messageOpenedAppSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    _tokenRefreshSubscription ??=
        _messaging.onTokenRefresh.listen(_registerTokenIfPossible);

    _initialized = true;
  }

  Future<void> syncForUser(UserDetails? user) async {
    if (kIsWeb || user == null) return;

    final inFlight = _syncInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final sync = _syncForUser(user).catchError((error, stackTrace) {
      debugPrint('Push notification sync failed: $error\n$stackTrace');
    });
    _syncInFlight = sync;

    try {
      await sync;
    } finally {
      if (identical(_syncInFlight, sync)) {
        _syncInFlight = null;
      }
    }
  }

  Future<void> _syncForUser(UserDetails? user) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();
    if (token == null) {
      return;
    }

    await _registerTokenIfPossible(token);
  }

  Future<void> unregisterCurrentToken() async {
    if (kIsWeb) {
      return;
    }

    final token = await SecureStorageService.getPushToken();
    if (token == null) {
      return;
    }

    try {
      await _repository.unregisterToken(token);
    } finally {
      await SecureStorageService.deletePushToken();
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedAppSubscription?.cancel();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;

        try {
          _emitNotificationTap(
            Map<String, dynamic>.from(jsonDecode(payload) as Map),
          );
        } catch (error) {
          debugPrint('Could not parse notification payload: $error');
        }
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _configureForegroundPresentation() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('Notification tap payload: ${message.data}');
    _emitNotificationTap(message.data);
  }

  void _emitNotificationTap(Map<String, dynamic> data) {
    final handler = _notificationTapHandler;
    if (handler == null) {
      _pendingNotificationTap = data;
      return;
    }

    handler(data);
  }

  Future<void> _registerTokenIfPossible(String token) async {
    try {
      final authToken = await SecureStorageService.getToken();
      if (authToken == null) return;

      final previousToken = await SecureStorageService.getPushToken();
      if (previousToken == token) return;

      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : defaultTargetPlatform == TargetPlatform.android
              ? 'android'
              : 'web';

      await _repository.registerToken(token: token, platform: platform);
      await SecureStorageService.setPushToken(token);
    } catch (error, stackTrace) {
      debugPrint('Push token registration failed: $error\n$stackTrace');
    }
  }
}
