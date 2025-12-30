import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/emotion_state.dart';
import '../../../ui/themes/colors.dart';

/// 情绪记录输入页面
/// 允许用户手动记录当前情绪
class EmotionInputScreen extends ConsumerStatefulWidget {
  const EmotionInputScreen({super.key});

  @override
  ConsumerState<EmotionInputScreen> createState() => _EmotionInputScreenState();
}

class _EmotionInputScreenState extends ConsumerState<EmotionInputScreen> {
  int _selectedLevel = 5;
  final TextEditingController _noteController = TextEditingController();

  final List<EmotionLevelOption> _options = [
    EmotionLevelOption(
      level: 1,
      label: '极度低落',
      icon: Icons.sentiment_very_dissatisfied,
      color: EmotionLevel.veryLow.color,
    ),
    EmotionLevelOption(
      level: 2,
      label: '低落',
      icon: Icons.sentiment_dissatisfied,
      color: EmotionLevel.low.color,
    ),
    EmotionLevelOption(
      level: 3,
      label: '不太好',
      icon: Icons.sentiment_neutral,
      color: EmotionLevel.neutral.color,
    ),
    EmotionLevelOption(
      level: 4,
      label: '还好',
      icon: Icons.sentiment_satisfied,
      color: EmotionLevel.good.color,
    ),
    EmotionLevelOption(
      level: 5,
      label: '良好',
      icon: Icons.sentiment_very_satisfied,
      color: EmotionLevel.excellent.color,
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('记录情绪'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
            const Text(
              '你现在感觉怎么样？',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '选择最符合你当前心情的选项',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 情绪选项
            ..._options.map((option) => _buildEmotionOption(option)),
            const SizedBox(height: 24),

            // 备注输入
            Text(
              '备注（可选）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: '记录一下你此刻的想法...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface.withOpacity(0.5),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // 提交按钮
            ElevatedButton(
              onPressed: _submitRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '保存记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionOption(EmotionLevelOption option) {
    final isSelected = _selectedLevel == option.level;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = option.level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withOpacity(0.2)
              : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? option.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 32,
              color: isSelected ? option.color : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? option.color : Colors.white,
                    ),
                  ),
                  if (isSelected)
                    const SizedBox(height: 4),
                  if (isSelected)
                    _buildLevelIndicator(option.level),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: option.color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    final stars = List.generate(
      (level / 2).ceil(),
      (index) => Icon(
        Icons.star,
        size: 14,
        color: Colors.white.withOpacity(0.8),
      ),
    );

    return Row(
      children: stars,
    );
  }

  void _submitRecord() {
    final note = _noteController.text.trim();
    ref.read(emotionStateProvider.notifier).addRecord(
      _selectedLevel,
      note: note.isEmpty ? null : note,
    );

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已记录：${_getLevelLabel(_selectedLevel)}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    // 返回上一页
    Navigator.pop(context);
  }

  String _getLevelLabel(int level) {
    switch (level) {
      case 1:
        return '极度低落';
      case 2:
        return '低落';
      case 3:
        return '不太好';
      case 4:
        return '还好';
      case 5:
        return '良好';
      default:
        return '正常';
    }
  }
}

/// 情绪选项
class EmotionLevelOption {
  final int level;
  final String label;
  final IconData icon;
  final Color color;

  EmotionLevelOption({
    required this.level,
    required this.label,
    required this.icon,
    required this.color,
  });
}
