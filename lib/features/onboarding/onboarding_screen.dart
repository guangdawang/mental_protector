import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/user_state.dart';
import '../../ui/themes/colors.dart';

/// 引导页面
/// 首次使用时展示应用功能说明
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.favorite,
      title: '欢迎来到心灵方舟',
      description: '我是你的心理健康守护者，24小时陪伴在你身边。',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.psychology,
      title: '智能情绪检测',
      description: '当你遇到困难时，我会通过智能分析及时发现，并为你提供支持。',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.phone_in_talk,
      title: '一键求助',
      description: '内置专业心理热线电话，一键即可获得专业帮助，完全离线可用。',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.contact_phone,
      title: '紧急联系人',
      description: '设置1-3个紧急联系人，在需要时可通过倒计时发送求助信息。',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.security,
      title: '隐私安全',
      description: '所有数据仅存储在本地设备，使用AES-256加密保护，完全由你掌控。',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.check_circle,
      title: '开始使用',
      description: '现在你可以开始使用心灵方舟了。记住，你从不孤单。',
      color: AppColors.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(),
                child: const Text(
                  '跳过',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // 底部指示器和按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 页面指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 导航按钮
                  _buildNavigationButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),

          // 标题
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 描述
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNavigationButton() {
    final isLastPage = _currentPage == _pages.length - 1;

    if (isLastPage) {
      // 最后一页显示完成按钮
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _completeOnboarding,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            '开始使用',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      // 其他页面显示下一页按钮
      return Row(
        children: [
          // 上一页按钮（不是第一页时显示）
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('上一页'),
              ),
            ),

          if (_currentPage > 0) const SizedBox(width: 16),

          // 下一页按钮
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('下一页'),
            ),
          ),
        ],
      );
    }
  }

  void _completeOnboarding() {
    // 标记已完成引导
    ref.read(userStateProvider.notifier).incrementUsageDays();
    widget.onCompleted();
  }
}

/// 引导页面数据模型
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
