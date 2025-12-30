import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../ui/themes/colors.dart';

/// 关于页面
/// 显示应用信息和开发者信息
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '心灵方舟',
    packageName: 'com.example.mindark_app',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('关于'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 应用图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 应用名称
            const Text(
              '心灵方舟',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MindDark',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '青少年心理健康守护应用',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),

            // 版本信息
            _buildInfoCard(
              icon: Icons.info,
              title: '版本',
              content: _packageInfo.version,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.code,
              title: '构建',
              content: _packageInfo.buildNumber,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.phone_android,
              title: '包名',
              content: _packageInfo.packageName,
            ),
            const SizedBox(height: 32),

            // 功能列表
            _buildSectionTitle('核心功能'),
            const SizedBox(height: 12),
            ..._buildFeatureList(),
            const SizedBox(height: 32),

            // 隐私政策
            _buildLinkCard(
              icon: Icons.privacy_tip,
              title: '隐私政策',
              subtitle: '了解我们如何保护你的数据',
              onTap: () => _launchUrl('https://example.com/privacy'),
            ),
            const SizedBox(height: 12),

            _buildLinkCard(
              icon: Icons.description,
              title: '使用条款',
              subtitle: '应用的使用条款和条件',
              onTap: () => _launchUrl('https://example.com/terms'),
            ),
            const SizedBox(height: 12),

            _buildLinkCard(
              icon: Icons.email,
              title: '联系我们',
              subtitle: '有建议或问题？发送邮件',
              onTap: () => _launchUrl('mailto:support@example.com'),
            ),
            const SizedBox(height: 12),

            _buildLinkCard(
              icon: Icons.star,
              title: '给我们评分',
              subtitle: '在应用商店为我们评分',
              onTap: () =>
                  _launchUrl('https://play.google.com/store/apps/details'),
            ),
            const SizedBox(height: 32),

            // 开源信息
            _buildOpenSourceCard(),
            const SizedBox(height: 32),

            // 版权信息
            Text(
              '© 2025 MindDark Team. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '用❤️为青少年心理健康守护',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  List<Widget> _buildFeatureList() {
    final features = [
      ('实时危机检测', Icons.security),
      ('安全岛呼吸练习', Icons.self_improvement),
      ('一键热线求助', Icons.phone_in_talk),
      ('紧急联系人', Icons.contact_phone),
      ('情绪记录历史', Icons.history),
      ('数据加密备份', Icons.backup),
      ('完全离线可用', Icons.offline_bolt),
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              feature.$2,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              feature.$1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenSourceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.code, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Text(
                '开源项目',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '本应用遵循开源协议，源代码公开，欢迎查看和贡献。',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _launchUrl('https://github.com/your-repo'),
            child: const Text(
              '查看源代码',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
