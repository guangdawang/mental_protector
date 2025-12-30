import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../detection/crisis_detector.dart';

/// 情绪状态
/// 记录用户的当前情绪状态
enum EmotionLevel {
  veryLow(1, '极度低落', Color(0xFFE74C3C)),
  low(3, '低落', Color(0xFFF39C12)),
  neutral(6, '平静', Color(0xFF4ECDC4)),
  good(8, '良好', Color(0xFF3498DB)),
  excellent(10, '非常好', Color(0xFF2ECC71));

  final int value;
  final String displayName;
  final Color color;

  const EmotionLevel(this.value, this.displayName, this.color);
}

/// 情绪记录
class EmotionRecord {
  final int level;
  final DateTime timestamp;
  final String? note;

  EmotionRecord({
    required this.level,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory EmotionRecord.fromJson(Map<String, dynamic> json) {
    return EmotionRecord(
      level: json['level'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }
}

/// 情绪状态管理器
class EmotionState {
  final EmotionLevel level;
  final DateTime lastUpdated;
  final List<EmotionRecord> history;
  final CrisisResult? lastCrisisDetection;

  EmotionState({
    EmotionLevel? level,
    DateTime? lastUpdated,
    List<EmotionRecord>? history,
    this.lastCrisisDetection,
  })  : level = level ?? EmotionLevel.neutral,
        lastUpdated = lastUpdated ?? DateTime.now(),
        history = history ?? [];

  /// 复制并更新状态
  EmotionState copyWith({
    EmotionLevel? level,
    DateTime? lastUpdated,
    List<EmotionRecord>? history,
    CrisisResult? lastCrisisDetection,
  }) {
    return EmotionState(
      level: level ?? this.level,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      history: history ?? this.history,
      lastCrisisDetection: lastCrisisDetection ?? this.lastCrisisDetection,
    );
  }

  /// 更新情绪等级
  EmotionState updateLevel(EmotionLevel newLevel) {
    // 添加记录到历史
    final newRecord = EmotionRecord(
      level: newLevel.value,
      timestamp: DateTime.now(),
    );

    final newHistory = [...history, newRecord];
    if (newHistory.length > 100) {
      newHistory.removeAt(0);
    }

    return copyWith(
      level: newLevel,
      lastUpdated: DateTime.now(),
      history: newHistory,
    );
  }

  /// 根据危机检测结果更新状态
  EmotionState handleCrisisDetection(CrisisResult result) {
    EmotionLevel newLevel = level;

    if (result.isCrisis) {
      switch (result.severity) {
        case CrisisSeverity.high:
          newLevel = EmotionLevel.veryLow;
          break;
        case CrisisSeverity.medium:
          newLevel = EmotionLevel.low;
          break;
        case CrisisSeverity.low:
          // 保持当前级别或略微降低
          if (level.value > 3) {
            newLevel = EmotionLevel.low;
          }
          break;
        case CrisisSeverity.none:
          break;
      }
    }

    return copyWith(
      level: newLevel,
      lastCrisisDetection: result,
      lastUpdated: DateTime.now(),
    );
  }

  /// 获取最近的情绪趋势（返回true表示上升，false表示下降）
  bool? getRecentTrend() {
    if (history.length < 2) return null;

    final recent = history.sublist(history.length - 5);
    if (recent.isEmpty) return null;

    final avgFirst = recent.take(recent.length ~/ 2).map((r) => r.level).reduce((a, b) => a + b) / (recent.length ~/ 2);
    final avgLast = recent.skip(recent.length ~/ 2).map((r) => r.level).reduce((a, b) => a + b) / (recent.length - recent.length ~/ 2);

    return avgLast >= avgFirst;
  }
}

/// 情绪状态Provider
final emotionStateProvider = StateNotifierProvider<EmotionStateNotifier, EmotionState>((ref) {
  return EmotionStateNotifier();
});

/// 情绪状态通知器
class EmotionStateNotifier extends StateNotifier<EmotionState> {
  EmotionStateNotifier() : super(EmotionState());

  /// 手动更新情绪等级
  void updateLevel(EmotionLevel level) {
    state = state.updateLevel(level);
  }

  /// 处理危机检测
  void handleCrisisDetection(CrisisResult result) {
    state = state.handleCrisisDetection(result);
  }

  /// 重置状态
  void reset() {
    state = EmotionState();
  }

  /// 添加情绪记录
  void addRecord(int level, {String? note}) {
    final record = EmotionRecord(
      level: level,
      timestamp: DateTime.now(),
      note: note,
    );

    final newHistory = [...state.history, record];
    if (newHistory.length > 100) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(history: newHistory);
  }
}
