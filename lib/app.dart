import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/themes/app_theme.dart';
import 'features/safe_harbor/screens/safe_harbor_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/emotion/screens/emotion_history_screen.dart';
import 'features/emotion/screens/emotion_input_screen.dart';
import 'core/detection/crisis_detector.dart';
import 'core/state/emotion_state.dart';
import 'core/state/first_launch_state.dart';

/// 主应用Widget
/// 配置全局主题和应用级设置
class MindDarkApp extends ConsumerWidget {
  const MindDarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstLaunchState = ref.watch(firstLaunchStateProvider);

    // 设置状态栏样式（深色模式）
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0A2342),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 设置横竖屏方向（仅竖屏）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 如果是首次启动，显示引导页面
    if (!firstLaunchState.hasSeenOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '心灵方舟',
        theme: AppTheme.darkTheme,
        home: OnboardingScreen(
          onCompleted: () {
            ref.read(firstLaunchStateProvider.notifier).markOnboardingSeen();
          },
        ),
      );
    }

    // 否则显示主应用
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '心灵方舟',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

/// 首页（包含测试输入检测功能）
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final emotionState = ref.watch(emotionStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        title: const Text('心灵方舟'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmotionHistoryScreen(),
                ),
              );
            },
            tooltip: '情绪记录',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 100,
              color: Color(0xFF4ECDC4),
            ),
            const SizedBox(height: 20),
            const Text(
              '心灵方舟',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '正在守护你的心灵',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            // 显示当前情绪状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: emotionState.level.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: emotionState.level.color,
                  width: 1,
                ),
              ),
              child: Text(
                '当前状态: ${emotionState.level.displayName}',
                style: TextStyle(
                  color: emotionState.level.color,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 快捷操作
            _buildQuickActions(context),
            ElevatedButton(
              onPressed: () {
                _showEmotionInput(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                '记录情绪',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                _showTestInput(context, ref);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
                side: const BorderSide(color: Color(0xFF4ECDC4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                '测试输入检测',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                _showManualSafeHarbor(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
                side: const BorderSide(color: Color(0xFF4ECDC4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                '手动进入安全岛',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestInput(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final startTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试输入检测'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入一些文字（试试"自杀"等关键词）',
          ),
          maxLines: 3,
          onChanged: (text) {
            // 实时检测
            if (CrisisDetector.quickDetect(text)) {
              Navigator.pop(context);
              final duration = DateTime.now().difference(startTime);

              final result = CrisisDetector.detect(
                text: text,
                inputDuration: duration,
              );

              // 更新情绪状态
              ref
                  .read(emotionStateProvider.notifier)
                  .handleCrisisDetection(result);

              // 进入安全岛
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SafeHarborScreen(
                    triggerReason: result.reason,
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text;
              Navigator.pop(context);

              // 即使没有关键词，也进行检测
              final duration = DateTime.now().difference(startTime);
              final result = CrisisDetector.detect(
                text: text,
                inputDuration: duration,
              );

              // 更新情绪状态
              ref
                  .read(emotionStateProvider.notifier)
                  .handleCrisisDetection(result);

              if (result.isCrisis) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SafeHarborScreen(
                      triggerReason: result.reason,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('未检测到危机内容')),
                );
              }
            },
            child: const Text('提交检测'),
          ),
        ],
      ),
    );
  }

  void _showEmotionInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmotionInputScreen(),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAction(
              icon: Icons.favorite_border,
              label: '心情',
              onTap: () {
                _showEmotionInput(context);
              },
            ),
            _buildQuickAction(
              icon: Icons.self_improvement,
              label: '放松',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SafeHarborScreen(
                      triggerReason: '手动进入',
                    ),
                  ),
                );
              },
            ),
            _buildQuickAction(
              icon: Icons.history,
              label: '历史',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmotionHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A5F).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4ECDC4),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualSafeHarbor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SafeHarborScreen(
          triggerReason: '手动进入',
        ),
      ),
    );
  }
}
