import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/state/emotion_state.dart';

/// 通知服务
/// 处理应用通知（情绪提醒、月度提醒等）
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<ReceivedNotification> _didReceiveLocalNotificationSubject =
      StreamController<ReceivedNotification>.broadcast();

  static final StreamController<String?> _selectNotificationSubject =
      StreamController<String?>.broadcast();

  /// 初始化通知服务
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// 显示情绪提醒通知
  static Future<void> showEmotionReminder({
    required String title,
    required String body,
    required int emotionLevel,
  }) async {
    final emotionLevelEnum = _getEmotionLevel(emotionLevel);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emotion_reminder_channel',
      '情绪提醒',
      channelDescription: '情绪状态变化提醒',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: 'emotion_reminder',
    );
  }

  /// 显示月度提醒通知
  static Future<void> showMonthlyReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'monthly_reminder_channel',
      '月度提醒',
      channelDescription: '每月检查设置提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💡 温馨提示',
      '已经一个月了，请检查一下你的紧急联系人和情绪状态',
      platformChannelSpecifics,
      payload: 'monthly_reminder',
    );
  }

  /// 取消所有通知
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 取消指定通知
  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static EmotionLevel _getEmotionLevel(int level) {
    if (level <= 2) return EmotionLevel.veryLow;
    if (level <= 4) return EmotionLevel.low;
    if (level <= 7) return EmotionLevel.neutral;
    if (level <= 9) return EmotionLevel.good;
    return EmotionLevel.excellent;
  }

  /// 获取通知流
  static Stream<ReceivedNotification> get didReceiveLocalNotificationStream {
    return _didReceiveLocalNotificationSubject.stream;
  }

  /// 获取通知选择流
  static Stream<String?> get onSelectNotificationStream {
    return _selectNotificationSubject.stream;
  }

  /// 释放资源
  static void dispose() {
    _didReceiveLocalNotificationSubject.close();
    _selectNotificationSubject.close();
  }
}

/// 收到的通知数据
class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });
}
