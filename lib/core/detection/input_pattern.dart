/// 输入模式分析器
/// 通过分析用户的输入行为模式检测潜在危机信号
class InputPattern {
  InputPattern._();

  /// 输入历史记录
  static final List<InputRecord> _history = [];

  /// 最大历史记录数量
  static const int maxHistorySize = 50;

  /// 添加一条输入记录
  static void addRecord(InputRecord record) {
    _history.add(record);
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
  }

  /// 分析输入模式，返回危机评分（0.0-1.0）
  static double analyzePattern() {
    if (_history.length < 3) return 0.0;

    double crisisScore = 0.0;

    // 1. 检测反复删除后重输（犹豫、焦虑）
    crisisScore += _detectHesitation();

    // 2. 检测极速输入（情绪激动）
    crisisScore += _detectRapidInput();

    // 3. 检测重复输入（思维卡顿）
    crisisScore += _detectRepetition();

    // 4. 检测深夜使用（情绪低谷时段）
    crisisScore += _detectLateNightUsage();

    // 确保分数在0-1之间
    return crisisScore.clamp(0.0, 1.0);
  }

  /// 检测犹豫行为（大量删除后重新输入）
  static double _detectHesitation() {
    if (_history.length < 3) return 0.0;

    int hesitationCount = 0;

    for (int i = 2; i < _history.length; i++) {
      final current = _history[i];
      final previous = _history[i - 1];

      // 判断是否删除后重输：前一条记录很长，当前记录较短
      if (previous.textLength > 20 && current.textLength < previous.textLength * 0.3) {
        hesitationCount++;
      }
    }

    // 计算犹豫比例
    final hesitationRatio = hesitationCount / (_history.length - 2);
    if (hesitationRatio > 0.4) return 0.35;
    if (hesitationRatio > 0.2) return 0.2;
    return 0.0;
  }

  /// 检测极速输入（每秒超过10个字符）
  static double _detectRapidInput() {
    if (_history.isEmpty) return 0.0;

    final recentRecords = _history.takeLast(5).toList();
    int rapidCount = 0;

    for (final record in recentRecords) {
      final charsPerSecond = record.textLength / record.duration.inSeconds;
      if (charsPerSecond > 10) {
        rapidCount++;
      }
    }

    if (rapidCount >= 3) return 0.4;
    if (rapidCount >= 1) return 0.2;
    return 0.0;
  }

  /// 检测重复输入（连续输入相同内容）
  static double _detectRepetition() {
    if (_history.length < 2) return 0.0;

    int repeatCount = 0;

    for (int i = 1; i < _history.length; i++) {
      final current = _history[i];
      final previous = _history[i - 1];

      // 判断是否重复（简单的文本相似度）
      if (current.text == previous.text) {
        repeatCount++;
      }
    }

    if (repeatCount >= 3) return 0.3;
    if (repeatCount >= 1) return 0.15;
    return 0.0;
  }

  /// 检测深夜使用（凌晨2-5点）
  static double _detectLateNightUsage() {
    if (_history.isEmpty) return 0.0;

    final now = DateTime.now();
    final hour = now.hour;

    // 凌晨2-5点
    if (hour >= 2 && hour < 5) {
      // 连续使用超过30分钟
      final firstRecord = _history.first;
      final duration = now.difference(firstRecord.timestamp);
      if (duration.inMinutes > 30) {
        return 0.25;
      }
    }

    return 0.0;
  }

  /// 清空历史记录
  static void clearHistory() {
    _history.clear();
  }

  /// 获取历史记录数量
  static int get historyCount => _history.length;
}

/// 输入记录数据模型
class InputRecord {
  final String text;
  final int textLength;
  final DateTime timestamp;
  final Duration duration;

  InputRecord({
    required this.text,
    required this.duration,
  })  : textLength = text.length,
        timestamp = DateTime.now();

  @override
  String toString() {
    return 'InputRecord(length: $textLength, duration: ${duration.inSeconds}s)';
  }
}

/// List扩展：获取最后n个元素
extension ListExtension<T> on List<T> {
  List<T> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}
