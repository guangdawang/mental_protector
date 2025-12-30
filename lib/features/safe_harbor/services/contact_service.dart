import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../data/models/contact_model.dart';
import '../../../core/constants.dart';

/// 紧急联系人服务
/// 处理紧急联系人的短信发送和倒计时
class ContactService {
  ContactService._();

  /// 触发紧急联系（带倒计时）
  static Future<bool> triggerEmergencyContact({
    required BuildContext context,
    required List<EmergencyContact> contacts,
    required VoidCallback onCountdownStart,
    required VoidCallback onCountdownCancel,
    required VoidCallback onCountdownComplete,
  }) async {
    if (contacts.isEmpty) {
      _showNoContactsDialog(context);
      return false;
    }

    // 开始倒计时
    onCountdownStart();

    // 显示倒计时对话框
    final result = await _showCountdownDialog(
      context,
      contacts,
      onCancel: () {
        onCountdownCancel();
      },
    );

    if (result == true) {
      // 倒计时完成，发送短信
      onCountdownComplete();
      return await _sendEmergencySMS(contacts);
    }

    return false;
  }

  /// 显示倒计时对话框
  static Future<bool?> _showCountdownDialog(
    BuildContext context,
    List<EmergencyContact> contacts, {
    required VoidCallback onCancel,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CountdownDialog(
        contacts: contacts,
        onCancel: onCancel,
      ),
    );
  }

  /// 发送紧急短信
  static Future<bool> _sendEmergencySMS(List<EmergencyContact> contacts) async {
    final message = '''
【心灵方舟自动发送】
我正在经历困难时刻，可能需要关心。
不需要立即回复，但希望你知道。

发送时间：${DateTime.now().toString().substring(0, 16)}
''';

    int successCount = 0;

    for (final contact in contacts) {
      final url = 'sms:${contact.phone}?body=${Uri.encodeComponent(message)}';

      try {
        if (await canLaunchUrlString(url)) {
          await launchUrlString(url);
          successCount++;
          // 等待2秒再发送下一个
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        print('发送短信失败: ${contact.name} - $e');
      }
    }

    return successCount > 0;
  }

  /// 显示无紧急联系人对话框
  static void _showNoContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未设置紧急联系人'),
        content: const Text('请先在设置中添加紧急联系人，以便在需要时获得帮助。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

/// 倒计时对话框
class _CountdownDialog extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final VoidCallback onCancel;

  const _CountdownDialog({
    required this.contacts,
    required this.onCancel,
  });

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _countdown = AppConstants.emergencyCountdownSeconds;
  bool _isCountingDown = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _countdown--;
      });

      // 8秒时轻微提醒
      if (_countdown == 8) {
        // 可以添加轻微振动
      }

      if (_countdown <= 0) {
        _isCountingDown = false;
        Navigator.of(context).pop(true); // 返回true表示完成
        return false;
      }

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactNames = widget.contacts
        .map((c) => c.name)
        .join('、');

    return AlertDialog(
      title: const Text('即将发送求助信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            size: 64,
            color: Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 16),
          Text(
            '$_countdown',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '秒后将自动联系：\n$contactNames',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            '你可以随时取消',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isCountingDown
              ? () {
                  widget.onCancel();
                  Navigator.of(context).pop(false);
                }
              : null,
          child: const Text('取消'),
        ),
      ],
    );
  }
}
