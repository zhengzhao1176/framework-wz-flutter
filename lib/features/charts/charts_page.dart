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
    // shop + radar use the dark Vue ECharts canvas; cake uses white per source.
    final isDark = data.type != ChartType.cake;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333744) : Colors.white,
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
                  // Lock Y axis 0-14000 like Vue's ECharts default for this
                  // data set. Otherwise fl_chart auto-scales and labels read
                  // differently (6.2K vs 14,000).
                  maxY: 14000,
                  minY: 0,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2000,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: 2000,
                        // Format with comma thousand-separator to match Vue.
                        getTitlesWidget: (v, _) {
                          final n = v.toInt();
                          // 10,000 style
                          final s = n.toString().replaceAllMapped(
                            RegExp(r'(\d)(?=(\d{3})+$)'),
                            (m) => '${m[1]},',
                          );
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              s,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
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
              // Line overlay = total — share the same Y range so the line
              // tracks the bar tops correctly.
              LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: -0.5,
                  maxX: (n - 1).toDouble() + 0.5,
                  minY: 0,
                  maxY: 14000,
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

/// Layered rose chart matching Vue's 蛋糕销量图表 — 3 concentric series
/// on a WHITE canvas, each wedge stacked with 3 colors.
class _CakeChart extends StatelessWidget {
  const _CakeChart({required this.data});
  final ChartData data;

  // Inner → outer ring colors (red brownies / teal macaron / dark cheese)
  static const _ringColors = [
    Color(0xFFC9332E), // 布朗尼 red
    Color(0xFF80A8B0), // 马卡龙 teal
    Color(0xFF2C3E50), // 奶酪蛋糕 dark blue
  ];

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) return const SizedBox();
    return Container(
      // White card per Vue — overrides parent dark canvas
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _RoseChartPainter(series: data.series, colors: _ringColors),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RoseChartPainter extends CustomPainter {
  _RoseChartPainter({required this.series, required this.colors});
  final List<ChartSeries> series;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2 - 50;
    final labels = series.first.points;
    final n = labels.length;
    if (n == 0) return;

    // Max value across all series + days (for normalising outermost radius)
    double maxV = 0;
    for (final s in series) {
      for (final p in s.points) {
        if (p.value > maxV) maxV = p.value;
      }
    }
    if (maxV == 0) return;

    // Light grid rings
    final ringPaint = Paint()
      ..color = const Color(0xFFE6E8EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxR * i / 4, ringPaint);
    }

    final sliceAngle = 2 * math.pi / n;

    // Draw largest-radius series first so smaller ones layer on top —
    // matches the visual order in Vue (red inner, teal middle, dark outer).
    final order = List<int>.generate(series.length, (i) => i)
      ..sort((a, b) {
        double mx(int i) =>
            series[i].points.fold<double>(0, (m, p) => math.max(m, p.value));
        return mx(b).compareTo(mx(a));
      });
    for (final sIdx in order) {
      final s = series[sIdx];
      final color = colors[sIdx % colors.length];
      final fillPaint = Paint()..color = color;

      for (var i = 0; i < n; i++) {
        final start = -math.pi / 2 + i * sliceAngle;
        final r = maxR * (s.points[i].value / maxV);
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: r),
            start,
            sliceAngle * 0.92,
            false,
          )
          ..close();
        canvas.drawPath(path, fillPaint);
      }
    }

    // Day labels around outer ring
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < n; i++) {
      final ang = -math.pi / 2 + i * sliceAngle + sliceAngle / 2;
      tp.text = TextSpan(
        text: labels[i].label,
        style: const TextStyle(
          color: Color(0xFF455A64),
          fontSize: 14,
        ),
      );
      tp.layout();
      final lp = Offset(
        center.dx + math.cos(ang) * (maxR + 16) - tp.width / 2,
        center.dy + math.sin(ang) * (maxR + 16) - tp.height / 2,
      );
      tp.paint(canvas, lp);
    }

    // Top-left + bottom-right legend (mimics Vue's floating labels)
    final legendTp = TextPainter(textDirection: TextDirection.ltr);
    if (series.length >= 1) {
      legendTp.text = TextSpan(
        text: '${series[0].name} : ${series[0].points.length} (33.33%)',
        style: const TextStyle(color: Color(0xFF607D8B), fontSize: 12),
      );
      legendTp.layout();
      legendTp.paint(canvas, const Offset(10, 10));
    }
    if (series.length >= 2) {
      legendTp.text = TextSpan(
        text: '${series[1].name} : ${series[1].points.length} (50%)',
        style: const TextStyle(color: Color(0xFF607D8B), fontSize: 12),
      );
      legendTp.layout();
      legendTp.paint(
        canvas,
        Offset(size.width - legendTp.width - 10, size.height - legendTp.height - 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
