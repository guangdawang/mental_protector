/// 关键词检测器
/// 检测用户输入中的危机相关关键词
class KeywordDetector {
  KeywordDetector._();

  /// 危机关键词列表（按优先级排序）
  static const List<String> crisisKeywords = [
    '自杀',
    '不想活了',
    '死了算了',
    '跳楼',
    '跳河',
    '跳桥',
    '割腕',
    '吃药',
    '解脱',
    '结束一切',
    '活不下去了',
    '人间不值得',
    '彻底绝望',
  ];

  /// 谐音/网络用语映射
  static const Map<String, String> slangMapping = {
    '紫砂': '自杀',
    '4️⃣了': '死了',
    '4了': '死了',
    '挂了': '死了',
    '走好': '死了',
    '升天': '死亡',
  };

  /// 检测文本是否包含危机关键词
  /// 返回检测到的关键词列表，如果没有则返回空列表
  static List<String> detectCrisis(String text) {
    if (text.isEmpty) return [];

    final detectedKeywords = <String>[];
    final normalizedText = _normalizeText(text);

    // 检测直接关键词
    for (final keyword in crisisKeywords) {
      if (normalizedText.contains(keyword)) {
        detectedKeywords.add(keyword);
      }
    }

    // 检测谐音/网络用语
    for (final entry in slangMapping.entries) {
      if (normalizedText.contains(entry.key)) {
        detectedKeywords.add('${entry.key}(${entry.value})');
      }
    }

    return detectedKeywords;
  }

  /// 快速检测（仅返回是否包含，不返回具体关键词）
  /// 用于实时输入检测，性能更高
  static bool hasCrisis(String text) {
    return detectCrisis(text).isNotEmpty;
  }

  /// 文本标准化
  /// 去除多余空格、统一符号等
  static String _normalizeText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), '') // 去除所有空白字符
        .toLowerCase(); // 转小写
  }

  /// 检测关键词的严重程度（1-10）
  /// 返回最高严重程度的关键词评分
  static int getSeverityScore(String text) {
    final keywords = detectCrisis(text);
    if (keywords.isEmpty) return 0;

    // 根据关键词类型给分
    int maxScore = 0;
    for (final keyword in keywords) {
      final score = _getKeywordScore(keyword);
      if (score > maxScore) maxScore = score;
    }

    return maxScore;
  }

  /// 获取单个关键词的严重程度评分
  static int _getKeywordScore(String keyword) {
    // 高危关键词（9-10分）
    const highRisk = ['自杀', '不想活了', '死了算了'];
    // 中危关键词（6-8分）
    const mediumRisk = ['跳楼', '跳河', '跳桥', '割腕', '吃药'];
    // 低危关键词（4-5分）
    const lowRisk = ['解脱', '结束一切', '活不下去了', '人间不值得', '彻底绝望'];

    if (highRisk.any(keyword.contains)) return 10;
    if (mediumRisk.any(keyword.contains)) return 8;
    if (lowRisk.any(keyword.contains)) return 5;

    return 4; // 谐音/网络用语默认4分
  }
}
