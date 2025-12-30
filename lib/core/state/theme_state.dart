import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题状态
class ThemeState {
  final bool isDarkMode;

  ThemeState({this.isDarkMode = true});

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// 主题状态Provider
final themeStateProvider = StateNotifierProvider<ThemeStateNotifier, ThemeState>((ref) {
  return ThemeStateNotifier();
});

/// 主题状态通知器
class ThemeStateNotifier extends StateNotifier<ThemeState> {
  ThemeStateNotifier() : super(ThemeState());

  /// 切换主题
  void toggleTheme() {
    final newMode = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newMode);
  }

  /// 设置主题
  void setTheme(bool isDarkMode) {
    state = state.copyWith(isDarkMode: isDarkMode);
  }
}
