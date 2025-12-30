import 'keyword_detector.dart';
import 'input_pattern.dart';

/// 危机检测器
/// 综合关键词检测和输入模式分析，判断用户是否处于危机状态
class CrisisDetector {
  CrisisDetector._();

  /// 检测危机状态
  /// 返回检测结果
  static CrisisResult detect({
    required String text,
    Duration? inputDuration,
    bool analyzePattern = true,
  }) {
    // 1. 关键词检测
    final keywords = KeywordDetector.detectCrisis(text);
    final severityScore = KeywordDetector.getSeverityScore(text);

    // 2. 如果有高危关键词，立即返回危机状态
    if (severityScore >= 9) {
      return CrisisResult(
        isCrisis: true,
        severity: CrisisSeverity.high,
        keywords: keywords,
        score: 0.9,
        reason: '检测到高危关键词',
      );
    }

    // 3. 添加输入记录（如果提供了输入时长）
    if (inputDuration != null) {
      InputPattern.addRecord(
        InputRecord(text: text, duration: inputDuration),
      );
    }

    // 4. 输入模式分析
    double patternScore = 0.0;
    String patternReason = '';

    if (analyzePattern) {
      patternScore = InputPattern.analyzePattern();
      if (patternScore > 0.3) {
        patternReason = '检测到异常输入模式';
      }
    }

    // 5. 综合评分
    final keywordScore = severityScore / 10.0; // 转换为0-1
    final finalScore = (keywordScore * 0.7) + (patternScore * 0.3);

    // 6. 判断是否为危机
    bool isCrisis = false;
    CrisisSeverity severity = CrisisSeverity.none;

    if (finalScore >= 0.6 || severityScore >= 6) {
      isCrisis = true;
      severity = severityScore >= 9
          ? CrisisSeverity.high
          : (severityScore >= 6 ? CrisisSeverity.medium : CrisisSeverity.low);
    }

    return CrisisResult(
      isCrisis: isCrisis,
      severity: severity,
      keywords: keywords,
      score: finalScore,
      reason: keywords.isNotEmpty
          ? '检测到关键词: ${keywords.join(", ")}'
          : patternReason,
    );
  }

  /// 快速检测（仅检测关键词，不做模式分析）
  static bool quickDetect(String text) {
    return KeywordDetector.hasCrisis(text);
  }
}

/// 危机检测结果
class CrisisResult {
  final bool isCrisis;
  final CrisisSeverity severity;
  final List<String> keywords;
  final double score; // 0.0-1.0
  final String reason;

  CrisisResult({
    required this.isCrisis,
    required this.severity,
    required this.keywords,
    required this.score,
    required this.reason,
  });

  @override
  String toString() {
    return 'CrisisResult(isCrisis: $isCrisis, severity: $severity, score: ${score.toStringAsFixed(2)}, reason: $reason)';
  }
}

/// 危机严重程度
enum CrisisSeverity {
  none,   // 无危机
  low,    // 低危
  medium, // 中危
  high,   // 高危
}

extension CrisisSeverityExtension on CrisisSeverity {
  String get displayName {
    switch (this) {
      case CrisisSeverity.none:
        return '正常';
      case CrisisSeverity.low:
        return '低危';
      case CrisisSeverity.medium:
        return '中危';
      case CrisisSeverity.high:
        return '高危';
    }
  }

  int get level {
    switch (this) {
      case CrisisSeverity.none:
        return 0;
      case CrisisSeverity.low:
        return 1;
      case CrisisSeverity.medium:
        return 2;
      case CrisisSeverity.high:
        return 3;
    }
  }
}
