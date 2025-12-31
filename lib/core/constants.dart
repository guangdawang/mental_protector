/// 应用常量定义
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '心灵方舟';
  static const String appVersion = '1.0.0';

  // 安全岛设置
  static const int emergencyCountdownSeconds = 10; // 倒计时10秒
  static const int maxEmergencyContacts = 3; // 最多3个紧急联系人
  static const int emergencyDisableDays = 90; // 关闭功能90天后过期

  // 情绪检测
  static const int initialEmotionScore = 6; // 初始情绪值
  static const int rapidInputThreshold = 10; // 每秒10字符算极速输入
  static const int lateNightStart = 2; // 凌晨2点
  static const int lateNightEnd = 5; // 凌晨5点
  static const int lateNightUsageMinutes = 30; // 深夜使用30分钟触发

  // 数据存储
  static const int maxEmotionHistory = 100; // 最多保留100条情绪记录
  static const int maxInputHistory = 50; // 最多保留50条输入记录
  static const String backupFileExtension = '.heart'; // 备份文件扩展名

  // 动画
  static const int breathingCycleSeconds = 6; // 呼吸循环6秒
  static const int heartbeatStartBPM = 70; // 初始心跳频率
  static const int heartbeatEndBPM = 60; // 目标心跳频率

  // 文件路径
  static const String databaseName = 'minddark_db';
  static const String encryptionKeyStorage = 'user_encryption_key';

  // 隐私
  static const int monthlyReminderDay = 1; // 每月1号提醒
}

/// 深夜时段常量
class LateNightHours {
  static const int start = 2; // 凌晨2点
  static const int end = 5; // 凌晨5点

  static bool isLateNight(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= start && hour < end;
  }
}

/// 呼吸阶段
enum BreathingPhase {
  inhale, // 吸气
  hold, // 屏息
  exhale, // 呼气
}
