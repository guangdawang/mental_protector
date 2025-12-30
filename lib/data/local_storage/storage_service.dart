import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact_model.dart';
import '../../core/state/emotion_state.dart';
import 'hive_adapters.dart';

/// 本地存储服务
/// 使用Hive进行本地数据持久化
class StorageService {
  StorageService._();

  /// 初始化Hive
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await HiveAdapters.registerAdapters();
    await HiveAdapters.openBoxes();
  }

  // ============ 紧急联系人 ============

  /// 获取紧急联系人Box
  static Box<EmergencyContact> get _contactsBox =>
      Hive.box<EmergencyContact>('emergency_contacts');

  /// 获取所有紧急联系人
  static List<EmergencyContact> getEmergencyContacts() {
    return _contactsBox.values.toList();
  }

  /// 添加紧急联系人
  static Future<void> addEmergencyContact(EmergencyContact contact) async {
    await _contactsBox.put(contact.id, contact);
  }

  /// 删除紧急联系人
  static Future<void> deleteEmergencyContact(String id) async {
    await _contactsBox.delete(id);
  }

  /// 更新紧急联系人
  static Future<void> updateEmergencyContact(EmergencyContact contact) async {
    await _contactsBox.put(contact.id, contact);
  }

  /// 清空所有紧急联系人
  static Future<void> clearEmergencyContacts() async {
    await _contactsBox.clear();
  }

  // ============ 情绪记录 ============

  /// 获取情绪记录Box
  static Box<EmotionRecord> get _emotionBox =>
      Hive.box<EmotionRecord>('emotion_records');

  /// 获取所有情绪记录
  static List<EmotionRecord> getEmotionRecords() {
    return _emotionBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 获取最近的情绪记录
  static List<EmotionRecord> getRecentEmotionRecords({int limit = 10}) {
    final records = getEmotionRecords();
    return records.length > limit
        ? records.sublist(records.length - limit)
        : records;
  }

  /// 添加情绪记录
  static Future<void> addEmotionRecord(EmotionRecord record) async {
    await _emotionBox.add(record);

    // 限制记录数量
    final records = getEmotionRecords();
    if (records.length > 100) {
      await _emotionBox.deleteAt(0);
    }
  }

  /// 清空情绪记录
  static Future<void> clearEmotionRecords() async {
    await _emotionBox.clear();
  }

  // ============ 用户设置 ============

  /// 获取用户设置Box
  static Box<String> get _settingsBox =>
      Hive.box<String>('user_settings');

  /// 设置键名
  static const String keyEmergencyEnabled = 'emergency_enabled';
  static const String keyEmergencyDisabledDate = 'emergency_disabled_date';
  static const String keyMonthlyReminder = 'monthly_reminder';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyAudioEnabled = 'audio_enabled';
  static const String keyAudioVolume = 'audio_volume';

  /// 获取布尔设置
  static bool? getBool(String key) {
    final value = _settingsBox.get(key);
    return value != null ? value == 'true' : null;
  }

  /// 设置布尔值
  static Future<void> setBool(String key, bool value) async {
    await _settingsBox.put(key, value.toString());
  }

  /// 获取字符串设置
  static String? getString(String key) {
    return _settingsBox.get(key);
  }

  /// 设置字符串
  static Future<void> setString(String key, String? value) async {
    if (value != null) {
      await _settingsBox.put(key, value);
    } else {
      await _settingsBox.delete(key);
    }
  }

  /// 获取整数设置
  static int? getInt(String key) {
    final value = _settingsBox.get(key);
    return value != null ? int.tryParse(value) : null;
  }

  /// 设置整数
  static Future<void> setInt(String key, int value) async {
    await _settingsBox.put(key, value.toString());
  }

  /// 获取浮点数设置
  static double? getDouble(String key) {
    final value = _settingsBox.get(key);
    return value != null ? double.tryParse(value) : null;
  }

  /// 设置浮点数
  static Future<void> setDouble(String key, double value) async {
    await _settingsBox.put(key, value.toString());
  }

  // ============ 数据备份 ============

  /// 导出所有数据为JSON
  static Map<String, dynamic> exportData() {
    return {
      'version': '1.0.0',
      'exportTime': DateTime.now().toIso8601String(),
      'emergencyContacts': getEmergencyContacts().map((c) => c.toJson()).toList(),
      'emotionRecords': getEmotionRecords().map((r) => r.toJson()).toList(),
      'settings': _settingsBox.toMap(),
    };
  }

  /// 导入JSON数据
  static Future<void> importData(Map<String, dynamic> data) async {
    // 清空现有数据
    await clearEmergencyContacts();
    await clearEmotionRecords();
    await _settingsBox.clear();

    // 导入紧急联系人
    if (data['emergencyContacts'] != null) {
      final contactsList = data['emergencyContacts'] as List;
      for (final contactJson in contactsList) {
        final contact = EmergencyContact.fromJson(contactJson);
        await addEmergencyContact(contact);
      }
    }

    // 导入情绪记录
    if (data['emotionRecords'] != null) {
      final recordsList = data['emotionRecords'] as List;
      for (final recordJson in recordsList) {
        final record = EmotionRecord.fromJson(recordJson);
        await addEmotionRecord(record);
      }
    }

    // 导入设置
    if (data['settings'] != null) {
      final settingsMap = data['settings'] as Map;
      for (final entry in settingsMap.entries) {
        await _settingsBox.put(entry.key, entry.value);
      }
    }
  }

  /// 清空所有数据
  static Future<void> clearAllData() async {
    await clearEmergencyContacts();
    await clearEmotionRecords();
    await _settingsBox.clear();
  }

  /// 获取数据统计
  static Map<String, int> getDataStats() {
    return {
      'contactsCount': getEmergencyContacts().length,
      'emotionRecordsCount': getEmotionRecords().length,
      'settingsCount': _settingsBox.length,
    };
  }
}
