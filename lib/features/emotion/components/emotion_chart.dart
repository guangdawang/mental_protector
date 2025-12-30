import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/contact_model.dart';
import '../../core/state/emotion_state.dart';
import '../../ui/themes/colors.dart';

/// 情绪趋势图表组件
/// 使用fl_chart显示情绪变化趋势
class EmotionChart extends StatelessWidget {
  final List<EmotionRecord> records;

  const EmotionChart({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyChart();
    }

    // 按时间排序
    final sortedRecords = List<EmotionRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 如果只有1条记录，显示单点
    if (sortedRecords.length == 1) {
      return _buildSinglePointChart(sortedRecords.first);
    }

    return _buildLineChart(sortedRecords);
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无数据',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePointChart(EmotionRecord record) {
    final emotionLevel = _getEmotionLevel(record.level);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${record.level}分',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: emotionLevel.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emotionLevel.displayName,
              style: TextStyle(
                fontSize: 18,
                color: emotionLevel.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<EmotionRecord> sortedRecords) {
    // 准备图表数据
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];
      spots.add(FlSpot(
        i.toDouble(),
        record.level.toDouble(),
      ));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: _buildGridData(),
          titlesData: _buildTitlesData(sortedRecords),
          borderData: _buildBorderData(),
          lineBarsData: [_buildLineBarData(spots)],
          minX: 0,
          maxX: (sortedRecords.length - 1).toDouble(),
          minY: 0,
          maxY: 10,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return [];
                final index = touchedSpots.first.spotIndex.toInt();
                final record = sortedRecords[index];
                final emotionLevel = _getEmotionLevel(record.level);
                return [
                  LineTooltipItem(
                    '${record.level}分',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ];
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 2,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.white.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData(List<EmotionRecord> records) {
    // 只显示部分日期（避免拥挤）
    final step = (records.length / 5).ceil();

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: step.toDouble(),
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= records.length) {
              return const Text('');
            }
            final index = value.toInt();
            if (index % step != 0) {
              return const Text('');
            }
            final record = records[index];
            final dateStr = _formatDateShort(record.timestamp);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                dateStr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 2,
          getTitlesWidget: (value, meta) {
            if (value == value.toInt() && value >= 0 && value <= 10) {
              return Text(
                '${value.toInt()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  LineBarData _buildLineBarData(List<FlSpot> spots) {
    return LineBarData(
      spots: spots,
      isCurved: true,
      color: AppColors.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final record = spots[index.toInt()].y.toInt();
          final emotionLevel = _getEmotionLevel(record);
          return FlDotCirclePainter(
            radius: 4,
            color: emotionLevel.color,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff < 7) return '${diff}天前';

    return '${date.month}/${date.day}';
  }

  EmotionLevel _getEmotionLevel(int level) {
    if (level <= 2) return EmotionLevel.veryLow;
    if (level <= 4) return EmotionLevel.low;
    if (level <= 7) return EmotionLevel.neutral;
    if (level <= 9) return EmotionLevel.good;
    return EmotionLevel.excellent;
  }
}

/// 简化版图表（不依赖fl_chart）
class SimpleEmotionChart extends StatelessWidget {
  final List<EmotionRecord> records;

  const SimpleEmotionChart({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyChart();
    }

    return _buildBarChart();
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无数据',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _EmotionChartPainter(records),
      ),
    );
  }
}

class _EmotionChartPainter extends CustomPainter {
  final List<EmotionRecord> records;

  _EmotionChartPainter(this.records);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 计算坐标
    final sortedRecords = List<EmotionRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final points = <Offset>[];
    final width = size.width - 32;
    final height = size.height - 32;

    for (int i = 0; i < sortedRecords.length; i++) {
      final x = 16 + (i / (sortedRecords.length - 1)) * width;
      final y = 16 + (1 - sortedRecords[i].level / 10) * height;
      points.add(Offset(x, y));
    }

    // 绘制填充区域
    final path = Path()
      ..moveTo(points.first.dx, size.height - 16)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      // 使用二次贝塞尔曲线
      final controlPoint = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        points[i].dx,
        points[i].dy,
      );
    }

    path.lineTo(points.last.dx, size.height - 16);
    path.close();

    canvas.drawPath(path, fillPaint);

    // 绘制线条
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final controlPoint = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      linePath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        points[i].dx,
        points[i].dy,
      );
    }

    canvas.drawPath(linePath, paint);

    // 绘制数据点
    for (int i = 0; i < points.length; i++) {
      final record = sortedRecords[i];
      final dotPaint = Paint()
        ..color = _getEmotionColor(record.level)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], 6, dotPaint);
    }

    // 绘制参考线
    _drawReferenceLines(canvas, size);
  }

  void _drawReferenceLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // 0分和10分参考线
    canvas.drawLine(
      Offset(16, size.height - 16),
      Offset(size.width - 16, size.height - 16),
      linePaint,
    );

    canvas.drawLine(
      Offset(16, 16),
      Offset(size.width - 16, 16),
      linePaint,
    );

    // 文本
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '10',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, 8));

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(canvas, Offset(4, size.height - 20));
  }

  Color _getEmotionColor(int level) {
    if (level <= 2) return EmotionLevel.veryLow.color;
    if (level <= 4) return EmotionLevel.low.color;
    if (level <= 7) return EmotionLevel.neutral.color;
    if (level <= 9) return EmotionLevel.good.color;
    return EmotionLevel.excellent.color;
  }

  @override
  bool shouldRepaint(_EmotionChartPainter oldDelegate) {
    return oldDelegate.records != records;
  }
}
