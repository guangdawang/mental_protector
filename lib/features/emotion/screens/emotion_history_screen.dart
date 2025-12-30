import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/emotion_state.dart';
import '../../../ui/themes/colors.dart';
import '../components/emotion_chart.dart';

/// 情绪历史页面
/// 展示用户的情绪记录和趋势
class EmotionHistoryScreen extends ConsumerStatefulWidget {
  const EmotionHistoryScreen({super.key});

  @override
  ConsumerState<EmotionHistoryScreen> createState() =>
      _EmotionHistoryScreenState();
}

class _EmotionHistoryScreenState extends ConsumerState<EmotionHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final emotionState = ref.watch(emotionStateProvider);
    final history = emotionState.history;

    // 过滤搜索结果
    final filteredHistory = _filterHistory(history, _searchQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('情绪记录'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.clear),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          if (_searchQuery.isNotEmpty || history.isNotEmpty) _buildSearchBar(),

          // 统计摘要
          if (history.isNotEmpty) _buildStatsCard(history),

          // 图表
          if (history.isNotEmpty) _buildChartSection(history),

          // 历史列表
          Expanded(
            child: filteredHistory.isEmpty
                ? _buildEmptySearchResult()
                : _buildHistoryList(filteredHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: '搜索记录...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<EmotionRecord> history) {
    final avgScore = history.isEmpty
        ? 0.0
        : history.map((r) => r.level).reduce((a, b) => a + b) / history.length;
    final maxScore = history.isEmpty
        ? 0
        : history.map((r) => r.level).reduce((a, b) => a > b ? a : b);
    final minScore = history.isEmpty
        ? 0
        : history.map((r) => r.level).reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('平均分', avgScore.toStringAsFixed(1)),
          _buildStatItem('最高', maxScore.toString()),
          _buildStatItem('最低', minScore.toString()),
          _buildStatItem('记录数', history.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(List<EmotionRecord> history) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '情绪趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SimpleEmotionChart(records: history),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Text(
            '未找到相关记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  List<EmotionRecord> _filterHistory(
      List<EmotionRecord> history, String query) {
    if (query.isEmpty) return history;

    final lowerQuery = query.toLowerCase();
    return history.where((record) {
      // 搜索备注
      if (record.note != null &&
          record.note!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // 搜索日期
      final dateStr = _formatDateSearch(record.timestamp);
      if (dateStr.contains(lowerQuery)) {
        return true;
      }
      // 搜索分数
      if (record.level.toString().contains(lowerQuery)) {
        return true;
      }
      return false;
    }).toList();
  }

  String _formatDateSearch(DateTime date) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(date);
  }

  Widget _buildHistoryList(List<EmotionRecord> history) {
    // 按日期分组
    final groupedRecords = _groupRecordsByDate(history);
    final groupList = groupedRecords.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final group = groupList[index];
        return _buildDateGroup(group);
      },
    );
  }

  Map<String, List<EmotionRecord>> _groupRecordsByDate(
      List<EmotionRecord> records) {
    final grouped = <String, List<EmotionRecord>>{};

    for (final record in records) {
      final dateKey = _formatDate(record.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(record);
    }

    return grouped;
  }

  Widget _buildDateGroup(MapEntry<String, List<EmotionRecord>> group) {
    final records = group.value;
    // 按时间排序
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            group.key,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // 记录卡片
        ...records.map((record) => _buildRecordCard(record)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecordCard(EmotionRecord record) {
    final emotionLevel = _getEmotionLevel(record.level);
    final trendIcon = _getTrendIcon(record.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 情绪指示器
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: emotionLevel.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        emotionLevel.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: emotionLevel.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      trendIcon,
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(record.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  if (record.note != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      record.note!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 评分
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: emotionLevel.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${record.level}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: emotionLevel.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(recordDate).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  EmotionLevel _getEmotionLevel(int level) {
    if (level <= 2) return EmotionLevel.veryLow;
    if (level <= 4) return EmotionLevel.low;
    if (level <= 7) return EmotionLevel.neutral;
    if (level <= 9) return EmotionLevel.good;
    return EmotionLevel.excellent;
  }

  Widget _getTrendIcon(int level) {
    // 简化实现：根据评分显示趋势
    if (level >= 7) {
      return const Icon(Icons.trending_up, color: AppColors.primary, size: 16);
    } else if (level <= 3) {
      return const Icon(Icons.trending_down, color: AppColors.error, size: 16);
    } else {
      return const Icon(Icons.trending_flat, color: AppColors.accent, size: 16);
    }
  }
}
