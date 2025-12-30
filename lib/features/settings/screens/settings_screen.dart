import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/user_state.dart';
import '../../../ui/themes/colors.dart';
import '../../../data/models/contact_model.dart';
import '../../backup/backup_service.dart';
import '../../../data/local_storage/storage_service.dart';
import 'dart:io';

/// 设置页面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);
    final settings = userState.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 紧急联系设置
          _buildEmergencySection(settings),

          const SizedBox(height: 24),

          // 通知设置
          _buildNotificationSection(settings),

          const SizedBox(height: 24),

          // 音频设置
          _buildAudioSection(settings),

          const SizedBox(height: 24),

          // 紧急联系人列表
          _buildContactsSection(settings),

          const SizedBox(height: 24),

          // 数据管理
          _buildDataSection(),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(UserSettings settings) {
    return _buildSection(
      title: '紧急联系',
      children: [
        SwitchListTile(
          title: const Text('启用紧急联系功能'),
          subtitle: Text(
            settings.emergencyEnabled
                ? '已启用（倒计时10秒后发送短信）'
                : settings.emergencyDisabledDate != null
                    ? '已禁用（${settings.emergencyDisabledDate!.toLocal().toString().split(' ')[0]}）'
                    : '未启用',
          ),
          value: settings.emergencyEnabled,
          onChanged: (value) {
            if (value) {
              _showEnableEmergencyDialog();
            } else {
              ref.read(userStateProvider.notifier).disableEmergencyContact();
              _showDisableSuccessDialog();
            }
          },
        ),
        if (!settings.emergencyEnabled && settings.needsMonthlyReminder())
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '你的紧急联系功能已关闭近2个月，建议重新启用',
                    style: TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationSection(UserSettings settings) {
    return _buildSection(
      title: '通知',
      children: [
        SwitchListTile(
          title: const Text('月度提醒'),
          subtitle: const Text('每月提醒检查紧急联系设置'),
          value: settings.monthlyReminderEnabled,
          onChanged: (value) {
            ref
                .read(userStateProvider.notifier)
                .setMonthlyReminderEnabled(value);
          },
        ),
        SwitchListTile(
          title: const Text('振动反馈'),
          subtitle: const Text('呼吸和操作时的振动提示'),
          value: settings.vibrationEnabled,
          onChanged: (value) {
            ref.read(userStateProvider.notifier).setVibrationEnabled(value);
          },
        ),
      ],
    );
  }

  Widget _buildAudioSection(UserSettings settings) {
    return _buildSection(
      title: '音频',
      children: [
        SwitchListTile(
          title: const Text('音频播放'),
          subtitle: const Text('安全岛中的心跳声'),
          value: settings.audioEnabled,
          onChanged: (value) {
            ref
                .read(userStateProvider.notifier)
                .setAudioSettings(enabled: value);
          },
        ),
        if (settings.audioEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '音量: ${(settings.audioVolume * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Slider(
                  value: settings.audioVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(settings.audioVolume * 100).toInt()}%',
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    ref
                        .read(userStateProvider.notifier)
                        .setAudioSettings(volume: value);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContactsSection(UserSettings settings) {
    return _buildSection(
      title: '紧急联系人',
      children: [
        if (settings.emergencyContacts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '暂无紧急联系人',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ...settings.emergencyContacts.map((contact) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.3),
              child: Text(
                contact.name[0],
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${contact.relationship} · ${contact.phone}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                _showDeleteContactDialog(contact.id);
              },
            ),
          );
        }),
        ListTile(
          leading: const Icon(Icons.add, color: AppColors.primary),
          title: const Text(
            '添加紧急联系人',
            style: TextStyle(color: AppColors.primary),
          ),
          onTap: _showAddContactDialog,
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: '数据管理',
      children: [
        ListTile(
          leading: const Icon(Icons.backup, color: AppColors.primary),
          title: const Text(
            '备份数据',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            '导出加密数据到本地',
            style: TextStyle(color: Colors.white54),
          ),
          onTap: () {
            _showBackupDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore, color: AppColors.primary),
          title: const Text(
            '恢复数据',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            '从备份文件恢复数据',
            style: TextStyle(color: Colors.white54),
          ),
          onTap: () {
            _showRestoreDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: AppColors.error),
          title: const Text(
            '清除所有数据',
            style: TextStyle(color: AppColors.error),
          ),
          subtitle: const Text(
            '删除所有本地数据',
            style: TextStyle(color: Colors.white54),
          ),
          onTap: _showClearDataDialog,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showEnableEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('启用紧急联系功能'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('此功能将在检测到危机时：'),
            SizedBox(height: 8),
            Text('• 10秒倒计时后自动发送短信'),
            Text('• 发送给预设的紧急联系人'),
            Text('• 你可以随时取消'),
            SizedBox(height: 12),
            Text('建议至少添加一个紧急联系人', style: TextStyle(color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userStateProvider.notifier).enableEmergencyContact();
              Navigator.pop(context);
              if (ref
                  .read(userStateProvider)
                  .settings
                  .emergencyContacts
                  .isEmpty) {
                _showAddContactDialog();
              } else {
                _showEnableSuccessDialog();
              }
            },
            child: const Text('启用'),
          ),
        ],
      ),
    );
  }

  void _showEnableSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            SizedBox(height: 16),
            Text('紧急联系功能已启用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showDisableSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            const Text('紧急联系功能已关闭'),
            const SizedBox(height: 8),
            Text(
              '将在90天后过期，届时系统会提醒你重新评估',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加紧急联系人'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                hintText: '例如：张三',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '电话号码',
                hintText: '例如：13800138000',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: '关系',
                hintText: '例如：爸爸、朋友',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final contact = EmergencyContact(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phone: phoneController.text,
                  relationship: relationshipController.text.isEmpty
                      ? '紧急联系人'
                      : relationshipController.text,
                );
                ref
                    .read(userStateProvider.notifier)
                    .addEmergencyContact(contact);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteContactDialog(String contactId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除紧急联系人'),
        content: const Text('确定要删除这个联系人吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref
                  .read(userStateProvider.notifier)
                  .removeEmergencyContact(contactId);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份数据'),
        content: const Text('是否使用标准加密强度备份数据？\n\n备份文件将保存到应用目录'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // 显示进度对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('正在备份...'),
                    ],
                  ),
                ),
              );

              try {
                final filepath = await BackupService.backupData();

                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                // 显示成功对话框
                if (context.mounted) {
                  _showBackupSuccessDialog(filepath);
                }
              } catch (e) {
                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                // 显示错误对话框
                if (context.mounted) {
                  _showErrorDialog('备份失败', e.toString());
                }
              }
            },
            child: const Text('开始备份'),
          ),
        ],
      ),
    );
  }

  void _showBackupSuccessDialog(String filepath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            const Text('数据已成功备份'),
            const SizedBox(height: 8),
            Text(
              '文件位置:\n${File(filepath).path.split('/').last}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await BackupService.shareBackup(filepath);
              } catch (e) {
                _showErrorDialog('分享失败', e.toString());
              }
            },
            child: const Text('分享'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复数据'),
        content: const Text('是否从备份文件恢复数据？\n\n注意：这将覆盖当前所有数据！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // 显示进度对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('正在恢复...'),
                    ],
                  ),
                ),
              );

              try {
                final success = await BackupService.selectAndRestoreBackup();

                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                if (success) {
                  // 重新加载设置
                  _reloadSettings();

                  // 显示成功对话框
                  if (context.mounted) {
                    _showRestoreSuccessDialog();
                  }
                }
              } catch (e) {
                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                // 显示错误对话框
                if (context.mounted) {
                  _showErrorDialog('恢复失败', e.toString());
                }
              }
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _showRestoreSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            const Text('数据已成功恢复'),
            const SizedBox(height: 8),
            Text(
              '部分设置可能需要重启应用生效',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _reloadSettings() {
    // 这里可以添加重新加载设置的逻辑
    // 例如从Hive重新读取设置并更新状态
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text(
          '确定要删除所有本地数据吗？\n\n此操作不可撤销！',
          style: TextStyle(color: AppColors.error),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);

              // 显示进度对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('正在清除...'),
                    ],
                  ),
                ),
              );

              try {
                await StorageService.clearAllData();

                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                // 显示成功对话框
                if (context.mounted) {
                  _showClearSuccessDialog();
                }
              } catch (e) {
                // 隐藏进度对话框
                if (context.mounted) Navigator.pop(context);

                // 显示错误对话框
                if (context.mounted) {
                  _showErrorDialog('清除失败', e.toString());
                }
              }
            },
            child: const Text('确定清除'),
          ),
        ],
      ),
    );
  }

  void _showClearSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            const Text('所有数据已清除'),
            const SizedBox(height: 8),
            Text(
              '应用将返回初始状态',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
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
