import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/colors.dart';

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

/// 主题设置页面
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('主题设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题选择
          _buildThemeOption(
            context,
            ref,
            title: '深色模式',
            subtitle: '适合夜间使用，护眼',
            icon: Icons.dark_mode,
            isSelected: themeState.isDarkMode,
            onTap: () {
              ref.read(themeStateProvider.notifier).setTheme(true);
            },
          ),
          const SizedBox(height: 16),
          _buildThemeOption(
            context,
            ref,
            title: '浅色模式',
            subtitle: '适合白天使用，明亮',
            icon: Icons.light_mode,
            isSelected: !themeState.isDarkMode,
            onTap: () {
              ref.read(themeStateProvider.notifier).setTheme(false);
            },
          ),
          const SizedBox(height: 32),

          // 说明
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    {
      required String title,
      required String subtitle,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '关于主题',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '深色模式是默认主题，采用深蓝色调，保护视力，适合夜间使用。\n\n'
            '浅色模式采用明亮色调，适合白天使用，提供更清晰的视觉效果。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
