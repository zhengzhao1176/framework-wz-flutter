import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Mirrors the original Vue /introduction page:
///   左侧：项目简介文字 + 后续规划
///   右侧：技术栈占比环形图（Vue 2976 / Webpack 1092 / Node 241 / CSS 59）
///   下方：3 张实践案例卡（Yi+ 内容审核 / 人脸识别 / 边看边买）
class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  static const _stack = [
    ('vue', 2976, Color(0xFFE53935)),
    ('webpack', 1092, Color(0xFF1E88E5)),
    ('node', 241, Color(0xFF43A047)),
    ('css', 59, Color(0xFFFB8C00)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (_, c) {
                final wide = c.maxWidth > 720;
                final intro = _IntroText();
                final chart = SizedBox(
                  height: 240,
                  child: _StackPieChart(stack: _stack),
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(width: 320, child: chart),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: AppSpacing.md), chart],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              '实践案例',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (_, c) {
            final cols = c.maxWidth < 720 ? 1 : 3;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.6,
              children: const [
                _PracticeCard(
                  title: 'Yi+ 内容审核平台',
                  body: '基于 WZ 开发的稳定高效的平台，用于涉黄、涉政、涉暴检测。',
                ),
                _PracticeCard(
                  title: 'Yi+ 人脸识别',
                  body: '基于 WZ 开发的人脸识别平台，采用行业领先的图像识别技术。',
                ),
                _PracticeCard(
                  title: 'Yi+ 边看边买',
                  body: '基于 WZ 框架开发的边看边买的视频推荐系统。',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _IntroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '一步步带你做 vue 后台管理框架(一)——介绍框架',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '一步步带你做 vue 后台管理框架(二)——上手使用',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          '后续教程正在日夜撰写中，接下来会讲一下登录鉴权、路由、webpack、自己动手封装 UI 组件等内容。',
          style: TextStyle(
            color: AppColors.textRegular,
            height: 1.7,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '希望大家能够根据此项目和教程开发出自己的框架，从而在工作学习中得心应手。',
          style: TextStyle(
            color: AppColors.textRegular,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _StackPieChart extends StatelessWidget {
  const _StackPieChart({required this.stack});
  final List<(String, int, Color)> stack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '项目占比',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 1,
              centerSpaceRadius: 32,
              sections: [
                for (final (name, val, color) in stack)
                  PieChartSectionData(
                    value: val.toDouble(),
                    color: color,
                    radius: 50,
                    title: '$name $val',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Wrap(
            spacing: AppSpacing.md,
            children: [
              for (final (name, val, color) in stack)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$name $val',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                body,
                style: const TextStyle(
                  color: AppColors.textRegular,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const Text(
              '立即访问',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
