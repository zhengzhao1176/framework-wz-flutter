import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key, required this.code});

  final int code;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    if (widget.code == 401) {
      _redirectTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) context.go(AppRoutes.login);
      });
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.code == 404) {
      return const _Page404();
    }
    return _GenericErrorPage(code: widget.code);
  }
}

/// Replica of the original Vue `Page404.vue`:
///   - Light-blue → near-white vertical gradient sky
///   - Big text "天啊。 / 那页失踪了。"
///   - "返回首页" link below
///   - Tree silhouettes near horizon
///   - White mound + half-buried red "404" text + tiny spade
class _Page404 extends StatelessWidget {
  const _Page404();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sky gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD9E3EE), Color(0xFFEFF3F8)],
                ),
              ),
            ),
          ),
          // Static snow dots
          Positioned.fill(
            child: CustomPaint(painter: _SnowPainter()),
          ),
          // Trees + ground
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280,
            child: _GroundLayer(),
          ),
          // Main text
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '天啊。',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0xFF606575),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Text(
                    '那页失踪了。',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0xFF606575),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    key: const Key('error.goHome'),
                    onTap: () => context.go(AppRoutes.dashboard),
                    child: const Text(
                      '返回首页',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  static final _rng = math.Random(42);
  static final _flakes = List.generate(
    150,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble() * 0.55),
  );
  static final _sizes = List.generate(150, (_) => _rng.nextDouble() * 2 + 0.8);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (var i = 0; i < _flakes.length; i++) {
      canvas.drawCircle(
        Offset(_flakes[i].dx * size.width, _flakes[i].dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GroundLayer extends StatelessWidget {
  const _GroundLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GroundPainter());
  }
}

class _GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Distant trees row
    final treePaint = Paint()..color = const Color(0xFF8A95B0).withValues(alpha: 0.55);
    final positions = [0.05, 0.12, 0.18, 0.24, 0.32, 0.40, 0.48, 0.58, 0.66, 0.74, 0.82, 0.92];
    final treeSizes = [40.0, 30.0, 50.0, 35.0, 45.0, 28.0, 60.0, 38.0, 32.0, 48.0, 36.0, 42.0];
    for (var i = 0; i < positions.length; i++) {
      final x = positions[i] * w;
      final ts = treeSizes[i];
      final path = Path()
        ..moveTo(x, h * 0.4)
        ..lineTo(x - ts / 2, h * 0.4 + ts * 1.4)
        ..lineTo(x + ts / 2, h * 0.4 + ts * 1.4)
        ..close();
      canvas.drawPath(path, treePaint);
    }

    // White ground (a wide oval at the bottom)
    final groundPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.95),
        width: w * 1.4,
        height: h * 0.55,
      ),
      groundPaint,
    );

    // Half-buried red "404"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '404',
        style: TextStyle(
          color: Color(0xFFC9332E),
          fontSize: 120,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(w / 2 - textPainter.width / 2 - 20, h * 0.6),
    );

    // Tiny shovel/spade to the right of 404
    final spadePaint = Paint()..color = const Color(0xFFC9332E);
    final spadeX = w / 2 + textPainter.width / 2 - 10;
    final spadeY = h * 0.66;
    canvas.drawRect(
      Rect.fromLTWH(spadeX, spadeY, 4, 60),
      spadePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(spadeX - 5, spadeY, 14, 6),
      spadePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GenericErrorPage extends StatelessWidget {
  const _GenericErrorPage({required this.code});
  final int code;

  String get _title => switch (code) {
        401 => '会话已过期',
        403 => '无权访问',
        500 => '服务器开小差',
        _ => '出错了',
      };

  String get _hint => switch (code) {
        401 => '即将自动跳转到登录页…',
        403 => '请联系管理员开通权限',
        500 => '稍候再试, 或联系运维',
        _ => '请稍后再试',
      };

  IconData get _icon => switch (code) {
        401 => Icons.lock_clock_outlined,
        403 => Icons.block,
        500 => Icons.cloud_off_outlined,
        _ => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$code',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 4,
            ),
          ),
          Icon(_icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(_title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(_hint, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            key: const Key('error.goHome'),
            onPressed: () => context.go(AppRoutes.dashboard),
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }
}
