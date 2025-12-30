import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/contact_model.dart';

/// 用户设置状态
class UserSettings {
  final bool emergencyEnabled;
  final List<EmergencyContact> emergencyContacts;
  final DateTime? emergencyDisabledDate;
  final bool monthlyReminderEnabled;
  final bool vibrationEnabled;
  final bool audioEnabled;
  final double audioVolume;

  UserSettings({
    this.emergencyEnabled = false,
    this.emergencyContacts = const [],
    this.emergencyDisabledDate,
    this.monthlyReminderEnabled = true,
    this.vibrationEnabled = true,
    this.audioEnabled = true,
    this.audioVolume = 0.3,
  });

  UserSettings copyWith({
    bool? emergencyEnabled,
    List<EmergencyContact>? emergencyContacts,
    DateTime? emergencyDisabledDate,
    bool? monthlyReminderEnabled,
    bool? vibrationEnabled,
    bool? audioEnabled,
    double? audioVolume,
  }) {
    return UserSettings(
      emergencyEnabled: emergencyEnabled ?? this.emergencyEnabled,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      emergencyDisabledDate: emergencyDisabledDate ?? this.emergencyDisabledDate,
      monthlyReminderEnabled: monthlyReminderEnabled ?? this.monthlyReminderEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      audioVolume: audioVolume ?? this.audioVolume,
    );
  }

  /// 检查紧急联系功能是否过期（3个月）
  bool isEmergencyExpired() {
    if (emergencyDisabledDate == null) return false;
    final expiryDate = emergencyDisabledDate!.add(const Duration(days: 90));
    return DateTime.now().isAfter(expiryDate);
  }

  /// 检查是否需要月度提醒
  bool needsMonthlyReminder() {
    if (!monthlyReminderEnabled) return false;
    if (emergencyEnabled) return false;
    if (emergencyDisabledDate == null) return false;

    // 如果关闭超过2个月，需要提醒
    final daysSinceDisabled = DateTime.now().difference(emergencyDisabledDate!).inDays;
    return daysSinceDisabled >= 60;
  }
}

/// 用户状态
class UserState {
  final String userId;
  final DateTime firstLaunchDate;
  final int usageDays;
  final UserSettings settings;

  UserState({
    String? userId,
    DateTime? firstLaunchDate,
    int? usageDays,
    UserSettings? settings,
  })  : userId = userId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        firstLaunchDate = firstLaunchDate ?? DateTime.now(),
        usageDays = usageDays ?? 1,
        settings = settings ?? UserSettings();

  UserState copyWith({
    String? userId,
    DateTime? firstLaunchDate,
    int? usageDays,
    UserSettings? settings,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      firstLaunchDate: firstLaunchDate ?? this.firstLaunchDate,
      usageDays: usageDays ?? this.usageDays,
      settings: settings ?? this.settings,
    );
  }

  /// 增加使用天数
  UserState incrementUsageDays() {
    return copyWith(usageDays: usageDays + 1);
  }

  /// 更新设置
  UserState updateSettings(UserSettings newSettings) {
    return copyWith(settings: newSettings);
  }
}

/// 用户状态Provider
final userStateProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});

/// 用户状态通知器
class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState());

  /// 开启紧急联系功能
  void enableEmergencyContact() {
    final newSettings = state.settings.copyWith(
      emergencyEnabled: true,
      emergencyDisabledDate: null,
    );
    state = state.updateSettings(newSettings);
  }

  /// 关闭紧急联系功能（3个月后过期）
  void disableEmergencyContact() {
    final newSettings = state.settings.copyWith(
      emergencyEnabled: false,
      emergencyDisabledDate: DateTime.now(),
    );
    state = state.updateSettings(newSettings);
  }

  /// 添加紧急联系人
  void addEmergencyContact(EmergencyContact contact) {
    final newContacts = [...state.settings.emergencyContacts, contact];
    if (newContacts.length > 3) {
      newContacts.removeAt(0); // 最多保留3个
    }
    final newSettings = state.settings.copyWith(emergencyContacts: newContacts);
    state = state.updateSettings(newSettings);
  }

  /// 删除紧急联系人
  void removeEmergencyContact(String contactId) {
    final newContacts = state.settings.emergencyContacts
        .where((c) => c.id != contactId)
        .toList();
    final newSettings = state.settings.copyWith(emergencyContacts: newContacts);
    state = state.updateSettings(newSettings);
  }

  /// 更新振动设置
  void setVibrationEnabled(bool enabled) {
    final newSettings = state.settings.copyWith(vibrationEnabled: enabled);
    state = state.updateSettings(newSettings);
  }

  /// 更新音频设置
  void setAudioSettings({bool? enabled, double? volume}) {
    final newSettings = state.settings.copyWith(
      audioEnabled: enabled ?? state.settings.audioEnabled,
      audioVolume: volume ?? state.settings.audioVolume,
    );
    state = state.updateSettings(newSettings);
  }

  /// 增加使用天数
  void incrementUsageDays() {
    state = state.incrementUsageDays();
  }

  /// 更新月度提醒设置
  void setMonthlyReminderEnabled(bool enabled) {
    final newSettings = state.settings.copyWith(
      monthlyReminderEnabled: enabled,
    );
    state = state.updateSettings(newSettings);
  }
}
