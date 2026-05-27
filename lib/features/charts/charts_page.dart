import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/async_view.dart';
import 'chart_models.dart';
import 'chart_providers.dart';

class ChartsPage extends ConsumerWidget {
  const ChartsPage({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ChartType.fromString(type);
    final data = ref.watch(chartDataProvider(t));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.subtitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncView<ChartData>(
                value: data,
                emptyChecker: (d) => d.isEmpty,
                onRetry: () => ref.invalidate(chartDataProvider(t)),
                dataBuilder: (d) => _ChartCanvas(data: d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCanvas extends StatelessWidget {
  const _ChartCanvas({required this.data});
  final ChartData data;

  @override
  Widget build(BuildContext context) {
    // Original Vue charts use a dark canvas. Wrap the chart in a dark
    // container to match.
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333744),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: switch (data.type) {
        ChartType.shop => _ShopChart(data: data),
        ChartType.radar => _RadarChart(data: data),
        ChartType.cake => _CakeChart(data: data),
      },
    );
  }
}

/// Stacked bar (women / men) with line overlay = "本年商场顾客男女人数统计"
class _ShopChart extends StatelessWidget {
  const _ShopChart({required this.data});
  final ChartData data;

  static const _femaleColor = Color(0xFFFF8A65);
  static const _maleColor = Color(0xFF26C6DA);
  static const _lineColor = Color(0xFFFFD740);

  @override
  Widget build(BuildContext context) {
    final female = data.series.firstWhere(
      (s) => s.name == '女' || s.name.contains('女'),
      orElse: () =>
          data.series.isNotEmpty ? data.series.first : const ChartSeries(name: '女', points: []),
    );
    final male = data.series.firstWhere(
      (s) => s.name == '男' || s.name.contains('男'),
      orElse: () => data.series.length > 1
          ? data.series[1]
          : const ChartSeries(name: '男', points: []),
    );

    // Stack values: women on bottom, men on top
    final n = female.points.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            _LegendDot(color: _femaleColor, label: '女'),
            SizedBox(width: AppSpacing.md),
            _LegendDot(color: _maleColor, label: '男'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Stack(
            children: [
              // Stacked bars (women bottom, men on top)
              BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2000,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: 2000,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= n) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${i + 1}月份',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < n; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: female.points[i].value +
                                (i < male.points.length ? male.points[i].value : 0),
                            rodStackItems: [
                              BarChartRodStackItem(
                                0,
                                female.points[i].value,
                                _femaleColor,
                              ),
                              if (i < male.points.length)
                                BarChartRodStackItem(
                                  female.points[i].value,
                                  female.points[i].value + male.points[i].value,
                                  _maleColor,
                                ),
                            ],
                            width: 28,
                            borderRadius: BorderRadius.zero,
                          ),
                        ],
                        showingTooltipIndicators: const [0],
                      ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: -8,
                      getTooltipColor: (_) => Colors.transparent,
                      getTooltipItem: (group, _, rod, __) {
                        final total = rod.toY.toInt();
                        return BarTooltipItem(
                          '$total',
                          const TextStyle(
                            color: _maleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Line overlay = total
              LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: -0.5,
                  maxX: (n - 1).toDouble() + 0.5,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      color: _lineColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      spots: [
                        for (var i = 0; i < n; i++)
                          FlSpot(
                            i.toDouble(),
                            female.points[i].value +
                                (i < male.points.length ? male.points[i].value : 0),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _RadarChart extends StatelessWidget {
  const _RadarChart({required this.data});
  final ChartData data;

  static const _seriesColors = [
    Color(0xFFE57373), // 预算 red
    Color(0xFF80CBC4), // 实际 teal
  ];

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) return const SizedBox();
    return Column(
      children: [
        // Legend
        Wrap(
          spacing: 16,
          children: [
            for (var i = 0; i < data.series.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: _seriesColors[i % _seriesColors.length],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.series[i].name,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            painter: _RadarPainter(
              series: data.series,
              colors: _seriesColors,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.series, required this.colors});
  final List<ChartSeries> series;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 60;
    final labels = series.first.points;
    final n = labels.length;
    // global max across all series so polygons share scale
    double maxV = 0;
    for (final s in series) {
      for (final p in s.points) {
        if (p.value > maxV) maxV = p.value;
      }
    }
    if (maxV == 0) return;

    final gridPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Concentric grid rings
    for (var ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * 2 * math.pi / n;
        final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Axis lines + labels
    final textPaint = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / n;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center, outer, gridPaint);

      textPaint.text = TextSpan(
        text: labels[i].label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
      textPaint.layout(maxWidth: 120);
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      final labelPos = Offset(
        center.dx + dx * (radius + 14) - textPaint.width / 2,
        center.dy + dy * (radius + 14) - textPaint.height / 2,
      );
      textPaint.paint(canvas, labelPos);
    }

    // Draw each series polygon
    for (var sIdx = 0; sIdx < series.length; sIdx++) {
      final s = series[sIdx];
      final color = colors[sIdx % colors.length];
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * 2 * math.pi / n;
        final r = radius * (s.points[i].value / maxV);
        final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

/// Polar bar / rose chart — each slice = a day, radius = value.
/// Mirrors Vue's "蛋糕销量" rose chart shape.
class _CakeChart extends StatelessWidget {
  const _CakeChart({required this.data});
  final ChartData data;

  static const _palette = [
    Color(0xFFC9332E),  // red
    Color(0xFF2C3E50),  // dark blue
    Color(0xFF6FA1A8),  // teal
    Color(0xFF2C3E50),
    Color(0xFF6FA1A8),
    Color(0xFFC9332E),
    Color(0xFF2C3E50),
  ];

  @override
  Widget build(BuildContext context) {
    final s = data.series.isNotEmpty ? data.series.first : null;
    if (s == null || s.points.isEmpty) return const SizedBox();
    return CustomPaint(
      painter: _PolarBarPainter(points: s.points, palette: _palette),
      child: const SizedBox.expand(),
    );
  }
}

class _PolarBarPainter extends CustomPainter {
  _PolarBarPainter({required this.points, required this.palette});
  final List<ChartPoint> points;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2 - 40;
    final n = points.length;
    final maxV = points.map((p) => p.value).fold<double>(0, math.max);
    if (maxV == 0) return;

    // outer ring
    final ringPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxR * i / 4, ringPaint);
    }

    // bars
    final sliceAngle = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final start = -math.pi / 2 + i * sliceAngle;
      final r = maxR * (points[i].value / maxV);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          start,
          sliceAngle * 0.92,
          false,
        )
        ..close();
      final paint = Paint()
        ..color = palette[i % palette.length].withValues(alpha: 0.85);
      canvas.drawPath(path, paint);
    }

    // labels around outer
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < n; i++) {
      final ang = -math.pi / 2 + i * sliceAngle + sliceAngle / 2;
      tp.text = TextSpan(
        text: points[i].label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
      tp.layout();
      final lp = Offset(
        center.dx + math.cos(ang) * (maxR + 16) - tp.width / 2,
        center.dy + math.sin(ang) * (maxR + 16) - tp.height / 2,
      );
      tp.paint(canvas, lp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
