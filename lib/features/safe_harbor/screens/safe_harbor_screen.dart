import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/breathing_circle.dart';
import '../services/hotline_service.dart';
import '../services/contact_service.dart';
import '../services/audio_generator_service.dart';
import '../../../core/state/user_state.dart';
import '../../../ui/themes/colors.dart';

/// 安全岛界面
/// 当检测到危机内容时自动进入
class SafeHarborScreen extends ConsumerStatefulWidget {
  final String? triggerReason;

  const SafeHarborScreen({
    super.key,
    this.triggerReason,
  });

  @override
  ConsumerState<SafeHarborScreen> createState() => _SafeHarborScreenState();
}

class _SafeHarborScreenState extends ConsumerState<SafeHarborScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeInController;
  bool _isPlayingAudio = false;
  String _currentAudioType = 'heartbeat';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAudio();
  }

  void _initAnimations() {
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  void _initAudio() async {
    _playHeartbeat();
  }

  void _playHeartbeat() async {
    final settings = ref.read(userStateProvider).settings;
    if (settings.audioEnabled) {
      try {
        await AudioGeneratorService.setVolume(settings.audioVolume);
        await AudioGeneratorService.playHeartbeat();
        _currentAudioType = 'heartbeat';
        setState(() => _isPlayingAudio = true);
      } catch (e) {
        print('播放心跳声失败: $e');
      }
    }
  }

  void _playBreathing() async {
    final settings = ref.read(userStateProvider).settings;
    if (settings.audioEnabled) {
      try {
        await AudioGeneratorService.setVolume(settings.audioVolume);
        await AudioGeneratorService.playBreathing();
        _currentAudioType = 'breathing';
        setState(() => _isPlayingAudio = true);
      } catch (e) {
        print('播放呼吸音失败: $e');
      }
    }
  }

  void _playWhiteNoise() async {
    final settings = ref.read(userStateProvider).settings;
    if (settings.audioEnabled) {
      try {
        await AudioGeneratorService.setVolume(settings.audioVolume);
        await AudioGeneratorService.playWhiteNoise();
        _currentAudioType = 'white_noise';
        setState(() => _isPlayingAudio = true);
      } catch (e) {
        print('播放白噪音失败: $e');
      }
    }
  }

  void _playPinkNoise() async {
    final settings = ref.read(userStateProvider).settings;
    if (settings.audioEnabled) {
      try {
        await AudioGeneratorService.setVolume(settings.audioVolume);
        await AudioGeneratorService.playPinkNoise();
        _currentAudioType = 'pink_noise';
        setState(() => _isPlayingAudio = true);
      } catch (e) {
        print('播放粉红噪音失败: $e');
      }
    }
  }

  void _stopAudio() {
    AudioGeneratorService.stop();
    setState(() => _isPlayingAudio = false);
  }

  void _switchAudio() async {
    switch (_currentAudioType) {
      case 'heartbeat':
        _playBreathing();
        break;
      case 'breathing':
        _playWhiteNoise();
        break;
      case 'white_noise':
        _playPinkNoise();
        break;
      case 'pink_noise':
        _playHeartbeat();
        break;
      default:
        _playHeartbeat();
    }
    _vibrate();
  }

  String _getAudioTypeLabel() {
    switch (_currentAudioType) {
      case 'heartbeat':
        return '心跳声';
      case 'breathing':
        return '呼吸引导';
      case 'white_noise':
        return '白噪音';
      case 'pink_noise':
        return '自然音';
      default:
        return '心跳声';
    }
  }

  void _vibrate() async {
    final settings = ref.read(userStateProvider).settings;
    if (settings.vibrationEnabled && (await Vibration.hasVibrator()) == true) {
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    AudioGeneratorService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInController,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // 星光背景
              const Starfield(),

              // 主要内容
              Column(
                children: [
                  // 顶部提示
                  _buildTopIndicator(),

                  // 中间呼吸区域
                  const Expanded(
                    child: Center(
                      child: BreathingCircle(
                        isActive: true,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // 底部操作按钮
                  _buildBottomActions(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '检测到可能需要帮助的内容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (widget.triggerReason != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.triggerReason!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final settings = ref.watch(userStateProvider).settings;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 热线电话按钮
          _buildHotlineButton(),

          const SizedBox(height: 12),

          // 紧急联系人按钮
          if (settings.emergencyEnabled &&
              settings.emergencyContacts.isNotEmpty)
            _buildEmergencyContactButton(),

          const SizedBox(height: 12),

          // 音频切换按钮
          if (settings.audioEnabled) _buildAudioSwitchButton(),

          const SizedBox(height: 12),

          // 返回按钮
          _buildExitButton(),
        ],
      ),
    );
  }

  Widget _buildHotlineButton() {
    final recommendedHotlines = HotlineService.getRecommendedHotlines();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: const Text(
          '一键拨打热线',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(
          Icons.phone_in_talk,
          color: AppColors.primary,
        ),
        children: recommendedHotlines.map((hotline) {
          return ListTile(
            title: Text(
              hotline.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              hotline.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                await HotlineService.callHotline(hotline.phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('拨打'),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmergencyContactButton() {
    final settings = ref.watch(userStateProvider).settings;
    final contactNames =
        settings.emergencyContacts.map((c) => c.name).join('、');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          _vibrate();
          await ContactService.triggerEmergencyContact(
            context: context,
            contacts: settings.emergencyContacts,
            onCountdownStart: () {},
            onCountdownCancel: () {},
            onCountdownComplete: () {
              Navigator.pop(context);
            },
          );
        },
        icon: const Icon(Icons.contact_phone),
        label: Text('联系紧急联系人（$contactNames）'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAudioSwitchButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: _switchAudio,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPlayingAudio ? Icons.volume_up : Icons.volume_off,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _isPlayingAudio ? _getAudioTypeLabel() : '点击播放音频',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ' (点击切换)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return TextButton.icon(
      onPressed: () {
        _showExitDialog();
      },
      icon: const Icon(Icons.arrow_back),
      label: const Text('返回'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withOpacity(0.6),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('是否返回？'),
        content: const Text('建议你多停留一会儿，让心情平复。\n如果需要，随时可以拨打热线电话。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('再待一会儿'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopAudio();
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }
}
