import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// 音频生成器服务
/// 程序化生成心跳声、呼吸引导音、白噪音等，无需外部音频文件
class AudioGeneratorService {
  AudioGeneratorService._();

  static AudioPlayer? _audioPlayer;
  static bool _isPlaying = false;
  static String? _currentType;

  /// 采样率
  static const int _sampleRate = 44100;
  static const int _channels = 1; // 单声道

  /// 初始化音频播放器
  static Future<void> _ensurePlayerInitialized() async {
    _audioPlayer ??= AudioPlayer();
    await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
  }

  /// 生成心跳声（脉冲波）
  static Future<void> playHeartbeat() async {
    await _ensurePlayerInitialized();

    if (_currentType == 'heartbeat' && _isPlaying) return;

    _stopCurrent();
    _currentType = 'heartbeat';

    // 生成心跳音频数据（60 bpm，每秒一个心跳）
    final duration = const Duration(seconds: 10); // 10秒循环
    final audioData = _generateHeartbeatAudio(duration);

    // 播放生成的音频
    try {
      final tempFile = await _writeToTempFile(audioData, 'heartbeat');
      await _audioPlayer!.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print('播放心跳声失败: $e');
      _isPlaying = false;
    }
  }

  /// 生成呼吸引导音（正弦波）
  static Future<void> playBreathing() async {
    await _ensurePlayerInitialized();

    if (_currentType == 'breathing' && _isPlaying) return;

    _stopCurrent();
    _currentType = 'breathing';

    // 生成呼吸引导音频（6秒循环：吸气2s + 屏息1s + 呼气3s）
    final duration = const Duration(seconds: 6); // 6秒循环
    final audioData = _generateBreathingAudio(duration);

    try {
      final tempFile = await _writeToTempFile(audioData, 'breathing');
      await _audioPlayer!.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print('播放呼吸音失败: $e');
      _isPlaying = false;
    }
  }

  /// 生成白噪音（放松背景音）
  static Future<void> playWhiteNoise() async {
    await _ensurePlayerInitialized();

    if (_currentType == 'white_noise' && _isPlaying) return;

    _stopCurrent();
    _currentType = 'white_noise';

    // 生成白噪音音频
    final duration = const Duration(seconds: 30); // 30秒循环
    final audioData = _generateWhiteNoiseAudio(duration);

    try {
      final tempFile = await _writeToTempFile(audioData, 'white_noise');
      await _audioPlayer!.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print('播放白噪音失败: $e');
      _isPlaying = false;
    }
  }

  /// 生成粉红噪音（更柔和的自然音）
  static Future<void> playPinkNoise() async {
    await _ensurePlayerInitialized();

    if (_currentType == 'pink_noise' && _isPlaying) return;

    _stopCurrent();
    _currentType = 'pink_noise';

    // 生成粉红噪音音频
    final duration = const Duration(seconds: 30);
    final audioData = _generatePinkNoiseAudio(duration);

    try {
      final tempFile = await _writeToTempFile(audioData, 'pink_noise');
      await _audioPlayer!.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print('播放粉红噪音失败: $e');
      _isPlaying = false;
    }
  }

  /// 停止播放
  static Future<void> stop() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
    }
    _isPlaying = false;
    _currentType = null;
  }

  /// 设置音量（0.0 - 1.0）
  static Future<void> setVolume(double volume) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
    }
  }

  /// 释放资源
  static Future<void> dispose() async {
    await stop();
    if (_audioPlayer != null) {
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
  }

  /// 停止当前播放
  static void _stopCurrent() {
    if (_isPlaying) {
      _audioPlayer?.stop();
    }
    _isPlaying = false;
  }

  // ========== 音频生成算法 ==========

  /// 生成心跳音频数据
  /// 使用两个短脉冲模拟"扑通"声
  static Uint8List _generateHeartbeatAudio(Duration duration) {
    final totalSamples = (_sampleRate * duration.inSeconds).toInt();
    final buffer = Float64List(totalSamples);

    // 心跳参数
    final beatInterval = _sampleRate ~/ 1; // 1秒一次心跳（60 bpm）
    final firstPulseDuration = _sampleRate ~/ 20; // 第一个脉冲50ms
    final secondPulseDuration = _sampleRate ~/ 15; // 第二个脉冲约66ms
    final pulseGap = _sampleRate ~/ 10; // 两个脉冲间隔100ms

    for (int i = 0; i < totalSamples; i++) {
      final beatIndex = i % beatInterval;

      // 第一个脉冲（"扑"）
      if (beatIndex < firstPulseDuration) {
        final progress = beatIndex / firstPulseDuration;
        // 正弦波包络
        final envelope = math.sin(progress * math.pi);
        // 正弦波形
        buffer[i] = 0.4 * envelope * math.sin(2 * math.pi * 60 * i / _sampleRate);
      }
      // 第二个脉冲（"通"）
      else if (beatIndex >= pulseGap &&
                 beatIndex < pulseGap + secondPulseDuration) {
        final localIndex = beatIndex - pulseGap;
        final progress = localIndex / secondPulseDuration;
        final envelope = math.sin(progress * math.pi);
        // 第二个脉冲频率略低
        buffer[i] = 0.3 * envelope * math.sin(2 * math.pi * 50 * i / _sampleRate);
      }
      // 静音
      else {
        buffer[i] = 0.0;
      }
    }

    return _float64ToWav(buffer);
  }

  /// 生成呼吸引导音频
  /// 使用频率渐变的正弦波模拟呼吸节奏
  static Uint8List _generateBreathingAudio(Duration duration) {
    final totalSamples = (_sampleRate * duration.inSeconds).toInt();
    final buffer = Float64List(totalSamples);

    // 呼吸周期：吸气2s + 屏息1s + 呼气3s = 6秒
    final inhaleSamples = (_sampleRate * 2).toInt();
    final holdSamples = (_sampleRate * 1).toInt();
    final exhaleSamples = (_sampleRate * 3).toInt();

    for (int i = 0; i < totalSamples; i++) {
      double amplitude = 0.0;
      double frequency = 440.0; // 基础频率440Hz

      // 吸气阶段（频率和音量渐升）
      if (i < inhaleSamples) {
        final progress = i / inhaleSamples;
        amplitude = 0.15 * progress; // 音量渐升
        frequency = 200.0 + (200.0 * progress); // 频率从200Hz渐升到400Hz
      }
      // 屏息阶段（静音）
      else if (i < inhaleSamples + holdSamples) {
        amplitude = 0.0;
      }
      // 呼气阶段（频率和音量渐降）
      else {
        final localIndex = i - inhaleSamples - holdSamples;
        final progress = localIndex / exhaleSamples;
        amplitude = 0.15 * (1.0 - progress); // 音量渐降
        frequency = 400.0 - (200.0 * progress); // 频率从400Hz渐降到200Hz
      }

      // 添加轻微颤音效果
      final tremolo = 1.0 + 0.1 * math.sin(2 * math.pi * 5 * i / _sampleRate);
      buffer[i] = amplitude * tremolo * math.sin(2 * math.pi * frequency * i / _sampleRate);
    }

    return _float64ToWav(buffer);
  }

  /// 生成白噪音
  /// 所有频率都有相同强度的随机信号
  static Uint8List _generateWhiteNoiseAudio(Duration duration) {
    final totalSamples = (_sampleRate * duration.inSeconds).toInt();
    final buffer = Float64List(totalSamples);

    final random = math.Random(42); // 固定种子以获得可重复的结果

    for (int i = 0; i < totalSamples; i++) {
      // 生成-1到1之间的随机值
      buffer[i] = (random.nextDouble() * 2 - 1) * 0.08; // 音量控制在8%
    }

    return _float64ToWav(buffer);
  }

  /// 生成粉红噪音
  /// 低频更丰富的自然声音，类似雨声、风声
  static Uint8List _generatePinkNoiseAudio(Duration duration) {
    final totalSamples = (_sampleRate * duration.inSeconds).toInt();
    final buffer = Float64List(totalSamples);

    // Pink噪声生成算法（Paul Kellet's refined method）
    double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
    final random = math.Random(42);

    for (int i = 0; i < totalSamples; i++) {
      final white = random.nextDouble() * 2 - 1;

      b0 = 0.99886 * b0 + white * 0.0555179;
      b1 = 0.99332 * b1 + white * 0.0750759;
      b2 = 0.96900 * b2 + white * 0.1538520;
      b3 = 0.86650 * b3 + white * 0.3104856;
      b4 = 0.55000 * b4 + white * 0.5329522;
      b5 = -0.7616 * b5 - white * 0.0168980;

      final pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
      b6 = white * 0.115926;

      buffer[i] = pink * 0.08; // 音量控制在8%
    }

    return _float64ToWav(buffer);
  }

  /// 写入音频数据到临时文件
  static Future<File> _writeToTempFile(Uint8List data, String name) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/$name$timestamp.wav');
    await tempFile.writeAsBytes(data);
    return tempFile;
  }

  /// 将Float64List转换为WAV格式字节
  /// WAV格式：PCM 16-bit, 单声道, 44100Hz
  static Uint8List _float64ToWav(Float64List samples) {
    final sampleCount = samples.length;
    final bytesPerSample = 2; // 16-bit
    final dataSize = sampleCount * bytesPerSample;
    final totalSize = 44 + dataSize; // WAV头44字节 + 数据

    final buffer = ByteData(totalSize);

    // WAV文件头
    // RIFF chunk
    _writeString(buffer, 0, 'RIFF');
    buffer.setUint32(4, totalSize - 8, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    // fmt chunk
    _writeString(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // fmt chunk size
    buffer.setUint16(20, 1, Endian.little); // PCM format
    buffer.setUint16(22, _channels, Endian.little); // channels
    buffer.setUint32(24, _sampleRate, Endian.little); // sample rate
    buffer.setUint32(28, _sampleRate * _channels * bytesPerSample, Endian.little); // byte rate
    buffer.setUint16(32, _channels * bytesPerSample, Endian.little); // block align
    buffer.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    _writeString(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    // 写入音频数据
    int offset = 44;
    for (int i = 0; i < sampleCount; i++) {
      // 将浮点值(-1.0到1.0)转换为16位整数(-32768到32767)
      final int16Value = (samples[i] * 32767.0).clamp(-32768, 32767).toInt();
      buffer.setInt16(offset, int16Value, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// 写入字符串到ByteData
  static void _writeString(ByteData buffer, int offset, String str) {
    for (int i = 0; i < str.length; i++) {
      buffer.setUint8(offset + i, str.codeUnitAt(i));
    }
  }
}
