import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动状态管理
class FirstLaunchState {
  final bool isFirstLaunch;
  final bool hasSeenOnboarding;

  FirstLaunchState({
    required this.isFirstLaunch,
    required this.hasSeenOnboarding,
  });

  FirstLaunchState copyWith({
    bool? isFirstLaunch,
    bool? hasSeenOnboarding,
  }) {
    return FirstLaunchState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}

/// 首次启动状态Provider
final firstLaunchStateProvider = StateNotifierProvider<FirstLaunchStateNotifier, FirstLaunchState>((ref) {
  return FirstLaunchStateNotifier();
});

/// 首次启动状态通知器
class FirstLaunchStateNotifier extends StateNotifier<FirstLaunchState> {
  FirstLaunchStateNotifier() : super(FirstLaunchState(isFirstLaunch: true, hasSeenOnboarding: false)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    state = FirstLaunchState(
      isFirstLaunch: isFirstLaunch,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  /// 标记已完成首次启动
  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    state = state.copyWith(isFirstLaunch: false);
  }

  /// 标记已完成引导
  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    state = state.copyWith(hasSeenOnboarding: true);
  }

  /// 重置状态（用于测试）
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', true);
    await prefs.setBool('has_seen_onboarding', false);
    state = FirstLaunchState(isFirstLaunch: true, hasSeenOnboarding: false);
  }
}
