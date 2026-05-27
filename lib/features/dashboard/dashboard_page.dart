import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/application/auth_providers.dart';

/// Mirrors the original Vue dashboard layout (AdminEx style):
///
///   ┌────────────────────────────────┬──────────────────────────┐
///   │  big multi-series area chart   │  Welcome popup (toast)   │
///   │                                │  User progress (Jane Doe)│
///   ├────────────────┬───────────────┼──────────────────────────┤
///   │  Calendar      │  TODO List    │  Date card (19 Feb)      │
///   │  May 2026      │  with bullets │  Mila Watson card        │
///   └────────────────┴───────────────┴──────────────────────────┘
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        LayoutBuilder(
          builder: (_, c) {
            final wide = c.maxWidth >= 1100;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: const [
                        _ChartCard(),
                        SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _CalendarCard()),
                            SizedBox(width: AppSpacing.md),
                            Expanded(child: _TodoCard()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        const _WelcomeCard(),
                        const SizedBox(height: AppSpacing.md),
                        _UserProgressCard(name: user?.name ?? '管理员'),
                        const SizedBox(height: AppSpacing.md),
                        const _DateCard(),
                        const SizedBox(height: AppSpacing.md),
                        const _MilaWatsonCard(),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                const _ChartCard(),
                const SizedBox(height: AppSpacing.md),
                const _CalendarCard(),
                const SizedBox(height: AppSpacing.md),
                const _TodoCard(),
                const SizedBox(height: AppSpacing.md),
                _UserProgressCard(name: user?.name ?? '管理员'),
                const SizedBox(height: AppSpacing.md),
                const _DateCard(),
                const SizedBox(height: AppSpacing.md),
                const _MilaWatsonCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ───────────────────────── Welcome notification ─────────────────────────

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.success),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.success,
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '欢迎使用 WZ 框架',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '你的账户权限是 admin',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '喜欢就去 github 给个 ⭐ start 鼓励一下吧',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.close, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ───────────────────────── Big area chart ─────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard();

  // Three data series matching the look of the original ECharts area chart.
  static const List<double> _seriesA = [
    8,10,14,18,22,28,32,30,25,21,16,12,16,20,24,28,34,38,40,38,
    34,30,28,24,22,20,18,17,16,15,14,
  ];
  static const List<double> _seriesB = [
    6,7,9,11,14,18,22,20,17,14,11,9,12,15,18,21,24,26,28,27,
    24,21,19,17,15,14,13,12,11,10,9,
  ];
  static const List<double> _seriesC = [
    3,4,5,7,9,12,15,13,11,9,7,6,8,10,12,14,16,18,19,18,
    16,14,13,11,10,9,8,7,7,6,5,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: _seriesA.length.toDouble() - 1,
              minY: 0,
              maxY: 50,
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 20,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 20,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 5,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _series(_seriesC, const Color(0xFFFFC0CB)),
                _series(_seriesB, const Color(0xFFB5E6FF)),
                _series(_seriesA, const Color(0xFFB7D7B7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _series(List<double> data, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 1,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.6),
      ),
      spots: [
        for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
      ],
    );
  }
}

// ───────────────────────── Calendar card ─────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF5EAFF0),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.chevron_left, color: Colors.white),
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        '2 0 2 6',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '5月',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const _CalendarGrid(),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid();

  static const _headers = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    // May 2026 starts on Friday → offset 4 (Mon=0..Sun=6)
    // Use a simplified layout
    return Column(
      children: [
        Row(
          children: [
            for (final h in _headers)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: TextStyle(
                      color:
                          h == '六' || h == '日' ? Colors.white : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (final week in _weeks())
          Row(
            children: [
              for (final day in week)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: day.today
                          ? const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            )
                          : null,
                      child: Text(
                        day.label,
                        style: TextStyle(
                          color: day.outside
                              ? Colors.white24
                              : (day.weekend
                                  ? Colors.white
                                  : Colors.white70),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // Hard-coded weeks for May 2026 starting Mon.
  List<List<_Day>> _weeks() {
    final out = <List<_Day>>[];
    // Previous month tail
    final apr = [27, 28, 29, 30];
    final may = [for (var d = 1; d <= 31; d++) d];
    final jun = [1, 2, 3, 4];
    final all = [
      ...apr.map((d) => _Day('$d', outside: true, weekend: false)),
      for (var i = 0; i < may.length; i++)
        _Day(
          '${may[i]}',
          outside: false,
          today: may[i] == 26,
          weekend: ((i + apr.length) % 7) >= 5,
        ),
      ...jun.map((d) => _Day('$d', outside: true, weekend: false)),
    ];
    for (var i = 0; i < all.length; i += 7) {
      out.add(all.sublist(i, (i + 7).clamp(0, all.length)));
    }
    return out;
  }
}

class _Day {
  const _Day(this.label, {this.outside = false, this.today = false, this.weekend = false});
  final String label;
  final bool outside;
  final bool today;
  final bool weekend;
}

// ───────────────────────── TODO list ─────────────────────────

class _TodoCard extends StatelessWidget {
  const _TodoCard();

  static const _todos = [
    '吾日七省吾身',
    'star this repository (给这个项目点星了吗？)',
    'fork this repository (fork这个项目了吗？)',
    'follow author (关注这个作者了吗？)',
    'read blogs (阅读教程了吗？)',
    'use and learn (学到新东西了吗？)',
    'make a cool project? (搞了一个牛项目吗？)',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_box_outline_blank,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'TODO LIST ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Text(
                  '(input sth here)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final t in _todos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  t,
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── User progress card ─────────────────────────

class _UserProgressCard extends StatelessWidget {
  const _UserProgressCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Text(
                        '- Marketing',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('60%',
                    style: TextStyle(color: AppColors.textRegular)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation(Color(0xFF5EAFF0)),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Date card ─────────────────────────

class _DateCard extends StatelessWidget {
  const _DateCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF5EAFF0),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '19 February 2014',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'AdminEx is new model of admin dashboard http://t.co/3laCVziTw4 4 days ago by John Doe',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Mila Watson card ─────────────────────────

class _MilaWatsonCard extends StatelessWidget {
  const _MilaWatsonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFA8A8),
              child: const Text('M',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mila Watson',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Senior UI Designer',
                    style: TextStyle(
                      color: Color(0xFFFFA8A8),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'I use to design websites and applications for the web.',
                    style: TextStyle(
                      color: AppColors.textRegular,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
