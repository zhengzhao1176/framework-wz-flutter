import 'package:flutter/material.dart';

/// Renders the original project's eagle logo asset.
///
/// The image is copied verbatim from `vue-framework-wz/static/img/logo.png`
/// — the same bitmap the Vue project shows in `.navbar-brand`.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48, this.collapsed = false});

  final double size;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: collapsed ? size : (size * 2.8),
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
