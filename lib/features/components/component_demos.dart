// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Shared section used by every demo page. Mirrors the iview "section + title +
/// description + content" pattern from the original Vue project.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLight,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          const Divider(height: AppSpacing.lg),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: children,
    );
  }
}

// ───────────────────────── Buttons ─────────────────────────

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  // iview Button styles converted to Flutter buttons.
  static Widget _btn(String text, {String type = 'default', bool disabled = false}) {
    final color = switch (type) {
      'primary' => AppColors.primary,
      'info' => const Color(0xFF2DB7F5),
      'success' => AppColors.success,
      'warning' => AppColors.warning,
      'error' => AppColors.danger,
      _ => null,
    };
    if (type == 'ghost') {
      return OutlinedButton(
        onPressed: disabled ? null : () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFDDDEE1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        ),
        child: Text(text),
      );
    }
    if (type == 'dashed') {
      return OutlinedButton(
        onPressed: disabled ? null : () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(
            color: Color(0xFFDDDEE1),
            style: BorderStyle.solid, // Flutter doesn't have dashed; we just use solid lighter
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        ),
        child: Text(text),
      );
    }
    if (type == 'text') {
      return TextButton(
        onPressed: disabled ? null : () {},
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        child: Text(text),
      );
    }
    if (type == 'default') {
      return OutlinedButton(
        onPressed: disabled ? null : () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFDDDEE1)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        ),
        child: Text(text),
      );
    }
    return ElevatedButton(
      onPressed: disabled ? null : () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      ),
      child: Text(text),
    );
  }

  static Widget _iconBtn(String type, IconData icon,
      {String? text, bool circle = false, String size = 'default'}) {
    final padding = switch (size) {
      'large' => const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      'small' => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      _ => const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
    };
    final shape = circle
        ? const StadiumBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
    final color = type == 'primary' ? AppColors.primary : null;
    final fg = type == 'primary' ? Colors.white : AppColors.textPrimary;
    final children = <Widget>[
      Icon(icon, size: 14, color: fg),
      if (text != null) ...[const SizedBox(width: 4), Text(text)],
    ];
    if (type == 'ghost' || type == 'default') {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: padding,
          shape: shape,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFDDDEE1)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      );
    }
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: padding,
        shape: shape,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  static Widget _group(List<Widget> children, {BorderRadius? radius}) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        // 1. 按钮类型
        DemoSection(
          title: '按钮类型',
          description:
              '按钮类型有: 默认按钮、主按钮、幽灵按钮、虚线按钮、文字按钮以及四种颜色按钮。\n通过设置 type 为 primary、ghost、dashed、text、info、success、warning、error 创建不同样式的按钮, 不设置为默认样式。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _btn('Default'),
                  _btn('Primary', type: 'primary'),
                  _btn('Ghost', type: 'ghost'),
                  _btn('Dashed', type: 'dashed'),
                  _btn('Text', type: 'text'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _btn('信息按钮', type: 'info'),
                  _btn('成功按钮', type: 'success'),
                  _btn('警告按钮', type: 'warning'),
                  _btn('错误按钮', type: 'error'),
                ],
              ),
            ],
          ),
        ),
        // 2. 图标按钮及按钮形状
        DemoSection(
          title: '图标按钮及按钮形状',
          description:
              '通过设置 icon 属性在 Button 内嵌入一个 Icon, 或者直接在 Button 内使用 Icon 组件。\n通过设置 shape 属性为 circle, 可将按钮置为圆的形状。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _iconBtn('primary', Icons.search, circle: true),
                  _iconBtn('primary', Icons.search, text: '搜索'),
                  _iconBtn('primary', Icons.search, text: '搜索', circle: true),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('圆角按钮'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _iconBtn('ghost', Icons.search, circle: true),
                  _iconBtn('ghost', Icons.search, text: '搜索'),
                  _iconBtn('ghost', Icons.search, text: '搜索', circle: true),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFFDDDEE1)),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('圆角按钮'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 3. 按钮尺寸
        DemoSection(
          title: '按钮尺寸',
          description:
              '按钮有三种尺寸: 大、默认（中）、小。\n通过设置 size 为 large 和 small 将按钮设置为大和小尺寸, 不设置为默认（中）尺寸。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text('Large'),
                  ),
                  _btn('Default', type: 'primary'),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Small'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text('Large'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Default'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Small'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 4. 长按钮
        DemoSection(
          title: '长按钮',
          description: '通过设置属性 long 可将按钮宽度设置为 100%，常用于弹窗内操作按钮。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('确认提交'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('确认删除'),
              ),
            ],
          ),
        ),
        // 5. 不可用状态
        DemoSection(
          title: '不可用状态',
          description: '通过添加 disabled 属性可将按钮设置为不可用状态。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn('Default'),
                _btn('Default(Disabled)', disabled: true),
              ]),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn('Primary', type: 'primary'),
                _btn('Primary(Disabled)', type: 'primary', disabled: true),
              ]),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn('Ghost', type: 'ghost'),
                _btn('Ghost(Disabled)', type: 'ghost', disabled: true),
              ]),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn('Dashed', type: 'dashed'),
                _btn('Dashed(Disabled)', type: 'dashed', disabled: true),
              ]),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn('Text', type: 'text'),
                _btn('Text(Disabled)', type: 'text', disabled: true),
              ]),
            ],
          ),
        ),
        // 6. 加载中状态
        DemoSection(
          title: '加载中状态',
          description:
              '通过添加 loading 属性可以让按钮处于加载中状态, 后两个按钮在点击时进入加载状态。',
          child: const _LoadingButtonsRow(),
        ),
        // 7. 按钮组合 — 简化为图标分组
        DemoSection(
          title: '按钮组合',
          description:
              '将多个 Button 放入 ButtonGroup 内, 可实现按钮组合的效果。\n通过设置 ButtonGroup 的属性 size 为 large 和 small, 可将按钮组尺寸设置为大和小。\n通过设置 shape 为 circle, 可将按钮组形状设置为圆角。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('基本', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: [
                _group([
                  _btn('取消'),
                  _btn('确定', type: 'primary'),
                ]),
                _group([
                  _btn('昨日', disabled: true),
                  _btn('今日', disabled: true),
                  _btn('明日', disabled: true),
                ]),
                _group([
                  _btn('L', type: 'primary'),
                  _btn('M'),
                  _btn('M', type: 'ghost'),
                  _btn('R', type: 'dashed'),
                ]),
              ]),
              const SizedBox(height: AppSpacing.md),
              const Text('配合图标', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: [
                _group([
                  _iconBtn('primary', Icons.chevron_left, text: '前进'),
                  _iconBtn('primary', Icons.chevron_right, text: '后退'),
                ]),
                _group([
                  _iconBtn('primary', Icons.skip_previous),
                  _iconBtn('primary', Icons.skip_next),
                ]),
                _group([
                  _iconBtn('ghost', Icons.auto_fix_high),
                  _iconBtn('ghost', Icons.wb_sunny_outlined),
                  _iconBtn('ghost', Icons.crop),
                  _iconBtn('ghost', Icons.filter_b_and_w),
                ]),
              ]),
              const SizedBox(height: AppSpacing.md),
              const Text('圆角', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: [
                _group(
                  [
                    _iconBtn('primary', Icons.chevron_left, text: '前进'),
                    _iconBtn('primary', Icons.chevron_right, text: '后退'),
                  ],
                  radius: BorderRadius.circular(20),
                ),
                _group(
                  [
                    _iconBtn('ghost', Icons.auto_fix_high),
                    _iconBtn('ghost', Icons.wb_sunny_outlined),
                    _iconBtn('ghost', Icons.crop),
                    _iconBtn('ghost', Icons.filter_b_and_w),
                  ],
                  radius: BorderRadius.circular(20),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingButtonsRow extends StatefulWidget {
  const _LoadingButtonsRow();
  @override
  State<_LoadingButtonsRow> createState() => _LoadingButtonsRowState();
}

class _LoadingButtonsRowState extends State<_LoadingButtonsRow> {
  bool _l1 = false;
  bool _l2 = false;

  Widget _btn({
    required bool loading,
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 14),
          if (loading || icon != null) const SizedBox(width: 6),
          Text(loading ? 'Loading...' : label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _btn(loading: true, onPressed: null, label: 'Loading...'),
        _btn(
          loading: _l1,
          onPressed: () => setState(() => _l1 = true),
          label: 'Click me!',
        ),
        _btn(
          loading: _l2,
          icon: Icons.check_circle_outline,
          onPressed: () => setState(() => _l2 = true),
          label: 'Click me!',
        ),
      ],
    );
  }
}

// ───────────────────────── Hover Buttons ─────────────────────────

class HoverButtonsDemo extends StatelessWidget {
  const HoverButtonsDemo({super.key});

  Widget _section(Color bg, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: bg,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '简单悬停样式',
          description:
              '适合主页跳转等场景使用, 简单大方。通过设置 type 为 height、width、lean, shap 为 full、half 创建不同样式。',
          child: _section(
            const Color(0xFF0E83CD),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: const [
                _HoverButton(text: 'HOVER ONE', style: _HoverStyle.heightFull),
                _HoverButton(text: 'HOVER TWO', style: _HoverStyle.heightHalf),
                _HoverButton(text: 'HOVER THREE', style: _HoverStyle.widthFull),
                _HoverButton(text: 'HOVER FOUR', style: _HoverStyle.widthHalf),
                _HoverButton(text: 'HOVER FIVE', style: _HoverStyle.lean),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '简单悬停按钮',
          description: '适合页面跳转及分页场景使用。',
          child: _section(
            const Color(0xFF2ECC71),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 14,
              children: const [
                _HoverButton(
                  text: 'Continue',
                  icon: Icons.arrow_circle_right_outlined,
                  style: _HoverStyle.arrowRight,
                ),
                _HoverButton(
                  text: 'Return',
                  icon: Icons.arrow_circle_left_outlined,
                  style: _HoverStyle.arrowLeft,
                ),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '普通悬停按钮',
          description: '最常用的几个功能性按钮。',
          child: _section(
            const Color(0xFF9E54BD),
            Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 14,
                  children: const [
                    _HoverButton(
                        text: 'Add to cart',
                        icon: Icons.shopping_cart_outlined,
                        style: _HoverStyle.changeTop),
                    _HoverButton(
                        text: 'Delete',
                        icon: Icons.delete_outline,
                        style: _HoverStyle.changeTop),
                    _HoverButton(
                        text: 'Settings',
                        icon: Icons.settings_outlined,
                        style: _HoverStyle.changeTop),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 14,
                  children: const [
                    _HoverButton(
                        text: 'Add to cart',
                        icon: Icons.shopping_cart_outlined,
                        style: _HoverStyle.changeLeft),
                    _HoverButton(
                        text: 'Delete',
                        icon: Icons.delete_outline,
                        style: _HoverStyle.changeLeft),
                    _HoverButton(
                        text: 'Settings',
                        icon: Icons.settings_outlined,
                        style: _HoverStyle.changeLeft),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '炫酷悬停按钮',
          description:
              '通过设置 type 为 swipe、close、zoningin、corners、slice、smoosh、overlap、collision 创建不同样式的按钮, 搭配 shap 属性使用更佳。',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _CoolHoverBtn('Settings'),
              _CoolHoverBtn('Diagonal Swipe'),
              _CoolHoverBtn('Double Swipe'),
              _CoolHoverBtn('Diagonal Close'),
              _CoolHoverBtn('Zoning In'),
              _CoolHoverBtn('4 Corners'),
              _CoolHoverBtn('Slice'),
              _CoolHoverBtn('Alternate'),
              _CoolHoverBtn('Smoosh'),
              _CoolHoverBtn('Vertical Overlap'),
              _CoolHoverBtn('Horizontal Overlap'),
              _CoolHoverBtn('Collision'),
            ],
          ),
        ),
      ],
    );
  }
}

enum _HoverStyle {
  heightFull,
  heightHalf,
  widthFull,
  widthHalf,
  lean,
  arrowRight,
  arrowLeft,
  changeTop,
  changeLeft,
}

class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.text, required this.style, this.icon});
  final String text;
  final IconData? icon;
  final _HoverStyle style;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hoverBg = switch (widget.style) {
      _HoverStyle.heightFull ||
      _HoverStyle.heightHalf ||
      _HoverStyle.widthFull ||
      _HoverStyle.widthHalf ||
      _HoverStyle.lean =>
        Colors.white.withValues(alpha: 0.18),
      _HoverStyle.arrowRight || _HoverStyle.arrowLeft =>
        Colors.white.withValues(alpha: 0.25),
      _HoverStyle.changeTop || _HoverStyle.changeLeft => Colors.white,
    };
    final txtColor = switch (widget.style) {
      _HoverStyle.changeTop ||
      _HoverStyle.changeLeft =>
        _hover ? Colors.purple : Colors.white,
      _ => Colors.white,
    };

    // .wz-hover { padding:25px 80px; border:3px solid #fff; margin:15px 30px; }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // padding 25 80 → about 230×80 inner
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 25),
          decoration: BoxDecoration(
            color: _hover ? hoverBg : Colors.transparent,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: txtColor, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cool-hover button — matches `.wz-coolhover-*` 1px-border 250×80 chips
/// from the original wzbutton.css. Each label has its own color.
class _CoolHoverBtn extends StatefulWidget {
  const _CoolHoverBtn(this.text);
  final String text;

  // Colors lifted directly from static/css/wzbutton.css.
  static const _colors = {
    'Settings': Color(0xFF9A3789),           // .swipe
    'Diagonal Swipe': Color(0xFFBC4B41),     // .swipe-in (out shares similar)
    'Double Swipe': Color(0xFFBC4B41),       // .swipe-in
    'Diagonal Close': Color(0xFF48A6B1),     // .close
    'Zoning In': Color(0xFFAD96A0),          // .zoningin
    '4 Corners': Color(0xFF8D53B3),          // .corners
    'Slice': Color(0xFF808695),              // .slice
    'Alternate': Color(0xFF27692B),          // .alternate
    'Smoosh': Color(0xFF5177A7),             // .smoosh
    'Vertical Overlap': Color(0xFFC93A8E),   // .overlap-vertical
    'Horizontal Overlap': Color(0xFF8F5C82), // .overlap-horizontal
    'Collision': Color(0xFF5C7A8E),          // .collision-ish
  };

  @override
  State<_CoolHoverBtn> createState() => _CoolHoverBtnState();
}

class _CoolHoverBtnState extends State<_CoolHoverBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = _CoolHoverBtn._colors[widget.text] ?? const Color(0xFF9A3789);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        // CSS: .wz-coolhover { width:100%; max-width:250px; height:80px;
        //                      line-height:80px; margin:20px auto; }
        width: 250,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _hover ? c : Colors.white,
          // border:1px solid currentColor
          border: Border.all(color: c, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          // text-transform: uppercase
          widget.text.toUpperCase(),
          style: TextStyle(
            color: _hover ? Colors.white : c,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Alert ─────────────────────────

class AlertDemo extends StatelessWidget {
  const AlertDemo({super.key});

  // iview Alert uses filled circular glyphs for info/success/warning/error
  // and an outlined lightbulb for the custom one.
  static Widget _alert(Color c, IconData icon, String title, String desc) =>
      Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          border: Border.all(color: c.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textRegular,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '基本使用方法，有四种样式可以选择 info、success、warning、error。',
          child: Column(
            children: [
              _alert(AppColors.info, Icons.info, '消息提示文案',
                  '消息提示时的描述文案 消息提示时的描述文案 消息提示时的描述文案'),
              _alert(AppColors.success, Icons.check_circle, '成功提示文案',
                  '成功的提示描述文案成功的提示描述文案'),
              _alert(AppColors.warning, Icons.error, '警告提示文案',
                  '警告的提示描述文案警告的提示描述文案'),
              _alert(AppColors.danger, Icons.cancel, '错误提示文案',
                  '自定义错误描述文案。'),
              _alert(AppColors.primary, Icons.lightbulb_outline, '自定义图标',
                  '自定义图标文案自定义图标文案自定义图标文案'),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Card ─────────────────────────

class CardDemo extends StatefulWidget {
  const CardDemo({super.key});
  @override
  State<CardDemo> createState() => _CardDemoState();
}

class _CardDemoState extends State<CardDemo> {
  static const _movies = <(String, double)>[
    ('肖申克的救赎', 9.6),
    ('这个杀手不太冷', 9.4),
    ('霸王别姬', 9.5),
    ('阿甘正传', 9.4),
    ('美丽人生', 9.5),
    ('千与千寻', 9.2),
    ('辛德勒的名单', 9.4),
    ('海上钢琴师', 9.2),
    ('机器人总动员', 9.3),
    ('盗梦空间', 9.2),
  ];
  late List<(String, double)> _picked;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final list = [..._movies]..shuffle();
    setState(() => _picked = list.take(5).toList());
  }

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基本用法',
          description: '自定义标题、额外操作和主体内容, 可以完全自由控制各个部分, 也可以结合其它组件一起使用, 较为灵活。',
          child: SizedBox(
            width: 350,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDDEE1)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFDDDEE1))),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.movie_outlined,
                            size: 16, color: AppColors.textPrimary),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            '经典电影',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: _shuffle,
                          child: Row(
                            children: const [
                              Icon(Icons.refresh,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                '换一换',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (name, rate) in _picked)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // bullet "•"
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                for (var i = 0; i < 4; i++)
                                  const Icon(Icons.star,
                                      size: 12, color: Color(0xFFFFAC2D)),
                                Icon(
                                  rate >= 9.5 ? Icons.star : Icons.star_half,
                                  size: 12,
                                  color: const Color(0xFFFFAC2D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rate.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── DatePicker ─────────────────────────

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});
  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? _date;
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '点击按钮调用日期选择面板，选择一个日期。',
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _date = d);
                },
                label: Text(_date == null
                    ? '选择日期'
                    : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '范围选择',
          description: '设置 type=daterange 即可选择起始时间和结束时间。',
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final r = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (r != null) setState(() => _range = r);
                },
                label: Text(_range == null
                    ? '选择日期范围'
                    : '${_range!.start.toIso8601String().split('T').first} ~ ${_range!.end.toIso8601String().split('T').first}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Form ─────────────────────────

class FormDemo extends StatefulWidget {
  const FormDemo({super.key});
  @override
  State<FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<FormDemo> {
  String? _city;
  String? _date;
  String? _time;
  String _radio = 'male';
  final _checks = <String>{};
  bool _switch = false;
  RangeValues _slider = const RangeValues(20, 50);
  String _textarea = '';

  Widget _label(String text, {double width = 80}) => SizedBox(
        width: width,
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );

  Widget _row(String label, Widget input) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('$label:'),
          Expanded(child: input),
        ],
      ),
    );
  }

  Widget _input({String? hint, double width = 220}) => SizedBox(
        width: width,
        height: 32,
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        // 行内表单
        DemoSection(
          title: '行内表单',
          description: '设置属性 inline, 表单元素可以水平排列。',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 32,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.person_outline, size: 16),
                    hintText: 'Username',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 200,
                height: 32,
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.lock_outline, size: 16),
                    hintText: 'Password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              ElevatedButton(onPressed: () {}, child: const Text('登录')),
            ],
          ),
        ),
        // 表单控件
        DemoSection(
          title: '表单控件',
          description:
              '在 Form 内, 每个表单域由 Form-item 组成, 可包含的控件有: Input、Radio、Checkbox、Switch、Select、Slider、DatePicker、TimePicker、Cascader、Transfer、InputNumber、Rate、Upload。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('输入框', _input(hint: '请输入')),
              _row(
                '选择器',
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _city,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '请选择',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'beijing', child: Text('北京市')),
                      DropdownMenuItem(value: 'shanghai', child: Text('上海市')),
                      DropdownMenuItem(value: 'shenzhen', child: Text('深圳市')),
                    ],
                    onChanged: (v) => setState(() => _city = v),
                  ),
                ),
              ),
              _row(
                '日期控件',
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );
                        if (d != null) {
                          setState(() => _date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDCDEE2)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _date ?? '选择日期',
                          style: TextStyle(
                            fontSize: 13,
                            color: _date == null
                                ? AppColors.textPlaceholder
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (t != null) {
                          setState(() => _time =
                              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDCDEE2)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _time ?? '选择时间',
                          style: TextStyle(
                            fontSize: 13,
                            color: _time == null
                                ? AppColors.textPlaceholder
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _row(
                '单选框',
                Wrap(spacing: 8, children: [
                  for (final (v, n) in [('male', '男'), ('female', '女')])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: v,
                          groupValue: _radio,
                          onChanged: (x) => setState(() => _radio = x!),
                        ),
                        Text(n, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                ]),
              ),
              _row(
                '多选框',
                Wrap(spacing: 8, children: [
                  for (final n in ['吃饭', '睡觉', '跑步', '看电影'])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _checks.contains(n),
                          onChanged: (s) => setState(() {
                            if (s == true) {
                              _checks.add(n);
                            } else {
                              _checks.remove(n);
                            }
                          }),
                        ),
                        Text(n, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                ]),
              ),
              _row(
                '开关',
                Row(children: [
                  Switch(
                    value: _switch,
                    onChanged: (v) => setState(() => _switch = v),
                  ),
                  const SizedBox(width: 8),
                  Text(_switch ? '开启' : '关闭',
                      style: const TextStyle(fontSize: 13)),
                ]),
              ),
              _row(
                '滑块',
                SizedBox(
                  width: 280,
                  child: RangeSlider(
                    values: _slider,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    labels: RangeLabels(
                      _slider.start.round().toString(),
                      _slider.end.round().toString(),
                    ),
                    onChanged: (v) => setState(() => _slider = v),
                  ),
                ),
              ),
              _row(
                '文本域',
                SizedBox(
                  width: 320,
                  child: TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '请输入...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => _textarea = v,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80, top: 8),
                child: Row(
                  children: [
                    ElevatedButton(onPressed: () {}, child: const Text('提交')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: const Text('取消')),
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

// ───────────────────────── Modal ─────────────────────────

class ModalDemo extends StatelessWidget {
  const ModalDemo({super.key});
  @override
  Widget build(BuildContext context) {
    // Vue source has a single button + standard Modal with title "普通的Modal对话框标题"
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '通过控制属性 visible(v-model) 的 true | false 来显示或隐藏对话框。',
          child: ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Container(
                  width: 500,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE9EAEC)),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '普通的Modal对话框标题',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close,
                                  size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Body
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('对话框内容', style: TextStyle(fontSize: 13)),
                            Text('对话框内容', style: TextStyle(fontSize: 13)),
                            Text('对话框内容', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE9EAEC)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('显示对话框'),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Select ─────────────────────────

class SelectDemo extends StatefulWidget {
  const SelectDemo({super.key});
  @override
  State<SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<SelectDemo> {
  static const _cityList = <(String, String)>[
    ('beijing', '北京市'),
    ('shanghai', '上海市'),
    ('shenzhen', '深圳市'),
    ('hangzhou', '杭州市'),
    ('nanjing', '南京市'),
    ('chongqing', '重庆市'),
  ];
  static const _hot = ['北京市', '上海市', '深圳市'];
  static const _other = ['杭州市', '南京市', '重庆市'];

  String? _v1;
  String? _v8;
  String? _v7;
  final Set<String> _v10 = {};
  String? _v11;
  final Set<String> _v12 = {};

  Widget _selector({
    required String? value,
    required List<(String, String)> items,
    required ValueChanged<String?> onChanged,
    double width = 200,
    bool clearable = false,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: [
          for (final (k, name) in items)
            DropdownMenuItem(value: k, child: Text(name)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _multi(Set<String> set, {double width = 260}) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDCDEE2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final (k, name) in _cityList)
              FilterChip(
                label: Text(name, style: const TextStyle(fontSize: 12)),
                selected: set.contains(k),
                onSelected: (s) {
                  setState(() {
                    if (s) {
                      set.add(k);
                    } else {
                      set.remove(k);
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description:
              '基本用法。可以使用 v-model 双向绑定数据。单选时, value 只接受字符串和数字类型, 多选时, 只接受数组类型。可以给 Select 添加 style 样式, 比如宽度。',
          child: _selector(
            value: _v1,
            items: _cityList,
            onChanged: (v) => setState(() => _v1 = v),
          ),
        ),
        DemoSection(
          title: '可清空',
          description: '通过设置属性 clearable 可以清空已选项, 仅适用于单选模式。',
          child: Row(
            children: [
              _selector(
                value: _v8,
                items: _cityList,
                onChanged: (v) => setState(() => _v8 = v),
              ),
              if (_v8 != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 18, color: Color(0xFFC5C8CE)),
                  onPressed: () => setState(() => _v8 = null),
                  tooltip: '清空',
                ),
              ],
            ],
          ),
        ),
        DemoSection(
          title: '分组',
          description: '使用 Option-group 可将选项进行分组。',
          child: SizedBox(
            width: 220,
            child: PopupMenuButton<String>(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDCDEE2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _v7 ?? '请选择',
                        style: TextStyle(
                          color: _v7 == null
                              ? AppColors.textPlaceholder
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
              onSelected: (v) => setState(() => _v7 = v),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('热门城市',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      )),
                ),
                for (final h in _hot)
                  PopupMenuItem(value: h, child: Text(h)),
                const PopupMenuItem(
                  enabled: false,
                  child: Text('其它城市',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      )),
                ),
                for (final o in _other)
                  PopupMenuItem(value: o, child: Text(o)),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '多选',
          description: '通过设置属性 multiple 可以开启多选模式。多选模式下, model 接受数组类型的数据, 所返回的也是数组。',
          child: _multi(_v10),
        ),
        DemoSection(
          title: '可搜索',
          description:
              '通过设置属性 filterable 可以开启搜索模式。单选和多选都支持搜索模式。多选搜索时, 可以使用键盘 Delete 快捷删除最后一个已选项。',
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _selector(
                value: _v11,
                items: _cityList,
                onChanged: (v) => setState(() => _v11 = v),
              ),
              _multi(_v12),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Spin ─────────────────────────

class SpinDemo extends StatelessWidget {
  const SpinDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '通过设置不同的尺寸、颜色，可以显示不同效果的加载状态。',
          child: Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator()),
              SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.success),
                  )),
              SizedBox(width: 200, child: LinearProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Steps ─────────────────────────

class StepsDemo extends StatelessWidget {
  const StepsDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '基本用法, 组件会根据 current 自动判断各步骤状态。',
          child: const _StepBar(
            current: 1,
            steps: [
              _StepData(title: '已完成', content: '这里是该步骤的描述信息'),
              _StepData(title: '进行中', content: '这里是该步骤的描述信息'),
              _StepData(title: '待进行', content: '这里是该步骤的描述信息'),
              _StepData(title: '待进行', content: '这里是该步骤的描述信息'),
            ],
          ),
        ),
        DemoSection(
          title: '带图标的步骤条',
          description: '通过设置 Step 的 icon 属性可以自定义图标。',
          child: const _StepBar(
            current: 1,
            steps: [
              _StepData(title: '注册', icon: Icons.person_add_alt),
              _StepData(title: '上传头像', icon: Icons.photo_camera_outlined),
              _StepData(title: '验证邮箱', icon: Icons.email_outlined),
            ],
          ),
        ),
        DemoSection(
          title: '垂直方向',
          description: '设置属性 direction 为 vertical 在垂直方向展示。',
          child: const _StepBar(
            current: 2,
            vertical: true,
            steps: [
              _StepData(title: '已完成', content: '这里是该步骤的描述信息'),
              _StepData(title: '已完成', content: '这里是该步骤的描述信息'),
              _StepData(title: '进行中', content: '这里是该步骤的描述信息'),
              _StepData(title: '待进行', content: '这里是该步骤的描述信息'),
            ],
          ),
        ),
        DemoSection(
          title: '步骤运行错误',
          description: '设置 Steps 的属性 status 为 error 指定当前步骤状态。',
          child: const _StepBar(
            current: 1,
            errorStatus: true,
            steps: [
              _StepData(title: '已完成', content: '这里是该步骤的描述信息'),
              _StepData(title: '进行中', content: '这里是该步骤的描述信息'),
              _StepData(title: '待进行', content: '这里是该步骤的描述信息'),
              _StepData(title: '待进行', content: '这里是该步骤的描述信息'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepData {
  const _StepData({required this.title, this.content, this.icon});
  final String title;
  final String? content;
  final IconData? icon;
}

class _StepBar extends StatelessWidget {
  const _StepBar({
    required this.current,
    required this.steps,
    this.vertical = false,
    this.errorStatus = false,
  });

  final int current;
  final List<_StepData> steps;
  final bool vertical;
  final bool errorStatus;

  Color _color(int i) {
    if (i < current) return AppColors.primary; // completed
    if (i == current) {
      if (errorStatus) return AppColors.danger;
      return AppColors.primary; // active
    }
    return const Color(0xFFC5C8CE); // pending
  }

  Widget _circle(int i, _StepData s) {
    final color = _color(i);
    final filled = i <= current;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: filled ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      alignment: Alignment.center,
      child: s.icon != null
          ? Icon(s.icon, size: 14, color: filled ? Colors.white : color)
          : (i < current
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: filled ? Colors.white : color,
                    fontSize: 13,
                  ),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _circle(i, steps[i]),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 1,
                            color: const Color(0xFFE9EAEC),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              steps[i].title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (steps[i].content != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                steps[i].content!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _circle(i, steps[i]),
              const SizedBox(height: 6),
              Text(
                steps[i].title,
                style: TextStyle(
                  color: i == current
                      ? (errorStatus ? AppColors.danger : AppColors.textPrimary)
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (steps[i].content != null)
                SizedBox(
                  width: 160,
                  child: Text(
                    steps[i].content!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(top: 13),
                color: i < current
                    ? AppColors.primary
                    : const Color(0xFFE9EAEC),
              ),
            ),
        ],
      ],
    );
  }
}

// ───────────────────────── Timeline ─────────────────────────

class TimelineDemo extends StatelessWidget {
  const TimelineDemo({super.key});

  Widget _itemTwoLine(int i, int n, String time, String content) =>
      _TimelineItem(
        last: i == n - 1,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(content, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    const events = <(String, String)>[
      ('1976年', 'Apple I 问世'),
      ('1984年', '发布 Macintosh'),
      ('2007年', '发布 iPhone'),
      ('2010年', '发布 iPad'),
      ('2011年10月5日', '史蒂夫·乔布斯去世'),
    ];
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '最简单定义一个时间轴的用法。',
          child: Column(
            children: [
              for (var i = 0; i < events.length; i++)
                _itemTwoLine(i, events.length, events[i].$1, events[i].$2),
            ],
          ),
        ),
        DemoSection(
          title: '圆圈颜色',
          description:
              '用各种颜色来标识不同状态, 可以使用 green、red、blue 或自定义的颜色, 默认是 blue。',
          child: Column(
            children: const [
              _TimelineItem(
                last: false,
                color: AppColors.success,
                child: Text('发布1.0版本', style: TextStyle(fontSize: 13)),
              ),
              _TimelineItem(
                last: false,
                color: AppColors.success,
                child: Text('发布2.0版本', style: TextStyle(fontSize: 13)),
              ),
              _TimelineItem(
                last: false,
                color: AppColors.danger,
                child: Text('严重故障', style: TextStyle(fontSize: 13)),
              ),
              _TimelineItem(
                last: true,
                color: AppColors.primary,
                child: Text('发布3.0版本', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.last,
    required this.color,
    required this.child,
  });

  final bool last;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 1,
                    color: const Color(0xFFE9EAEC),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.md),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Transfer ─────────────────────────

class TransferDemo extends StatefulWidget {
  const TransferDemo({super.key});
  @override
  State<TransferDemo> createState() => _TransferDemoState();
}

class _TransferItem {
  const _TransferItem(this.key, this.label, this.description);
  final String key;
  final String label;
  final String description;
}

class _TransferDemoState extends State<TransferDemo> {
  late List<_TransferItem> _data1;
  late Set<String> _targetKeys1;
  late List<_TransferItem> _data3;
  late Set<String> _targetKeys3;
  String _filter3 = '';

  List<_TransferItem> _genData() {
    return [
      for (var i = 1; i <= 20; i++)
        _TransferItem('$i', '内容$i', '内容$i 的描述信息'),
    ];
  }

  Set<String> _genTargets() {
    final list = _genData();
    return {
      for (final e in list)
        if (DateTime.now().microsecondsSinceEpoch ~/ 17 % 2 == 0
                ? true
                : (int.tryParse(e.key) ?? 0) % 2 == 0)
          e.key,
    };
  }

  @override
  void initState() {
    super.initState();
    _data1 = _genData();
    _targetKeys1 = _genTargets();
    _data3 = _genData();
    _targetKeys3 = _genTargets();
  }

  void _reload() {
    setState(() {
      _data3 = _genData();
      _targetKeys3 = _genTargets();
      _filter3 = '';
    });
  }

  Widget _transferList({
    required List<_TransferItem> data,
    required Set<String> targets,
    required bool rightSide,
    required ValueChanged<String> onToggle,
    required Size size,
    bool filterable = false,
    bool showDescription = false,
    String filter = '',
  }) {
    final items = data.where((e) {
      final inTarget = targets.contains(e.key);
      if (rightSide != inTarget) return false;
      if (filterable && filter.isNotEmpty) {
        return e.label.contains(filter) || e.description.contains(filter);
      }
      return true;
    }).toList();

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDCDEE2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F9),
                border:
                    Border(bottom: BorderSide(color: Color(0xFFDCDEE2))),
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length}/${data.where((e) => targets.contains(e.key) == rightSide).length} 项',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (filterable)
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 28,
                  child: TextField(
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '请输入搜索内容',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => setState(() => _filter3 = v),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final e in items)
                    InkWell(
                      onTap: () => onToggle(e.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: targets.contains(e.key) == rightSide
                                  ? targets.contains(e.key)
                                  : false,
                              onChanged: (_) => onToggle(e.key),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: showDescription
                                  ? Text(
                                      '${e.label} - ${e.description}',
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : Text(
                                      e.label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description:
              '基本用法, 展示了 data、target-keys、每行的渲染函数 render-format 以及回调函数 on-change 的用法。',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _transferList(
                data: _data1,
                targets: _targetKeys1,
                rightSide: false,
                size: const Size(160, 220),
                onToggle: (k) => setState(() {
                  if (_targetKeys1.contains(k)) {
                    _targetKeys1.remove(k);
                  } else {
                    _targetKeys1.add(k);
                  }
                }),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 18),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(width: 16),
              _transferList(
                data: _data1,
                targets: _targetKeys1,
                rightSide: true,
                size: const Size(160, 220),
                onToggle: (k) => setState(() {
                  if (_targetKeys1.contains(k)) {
                    _targetKeys1.remove(k);
                  } else {
                    _targetKeys1.add(k);
                  }
                }),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '高级用法',
          description:
              '穿梭框高级用法, 可以自定义两列的宽高、操作文案, 以及底部自定义操作, 更多配置见 API。',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _transferList(
                data: _data3,
                targets: _targetKeys3,
                rightSide: false,
                filterable: true,
                showDescription: true,
                filter: _filter3,
                size: const Size(250, 300),
                onToggle: (k) => setState(() {
                  if (_targetKeys3.contains(k)) {
                    _targetKeys3.remove(k);
                  } else {
                    _targetKeys3.add(k);
                  }
                }),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('向左移动'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('向右移动'),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _transferList(
                    data: _data3,
                    targets: _targetKeys3,
                    rightSide: true,
                    filterable: true,
                    showDescription: true,
                    filter: _filter3,
                    size: const Size(250, 260),
                    onToggle: (k) => setState(() {
                      if (_targetKeys3.contains(k)) {
                        _targetKeys3.remove(k);
                      } else {
                        _targetKeys3.add(k);
                      }
                    }),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: _reload,
                      child: const Text('刷新'),
                    ),
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

// ───────────────────────── TimePicker ─────────────────────────

class TimepickerDemo extends StatefulWidget {
  const TimepickerDemo({super.key});
  @override
  State<TimepickerDemo> createState() => _TimepickerDemoState();
}

class _TimepickerDemoState extends State<TimepickerDemo> {
  String _v1 = '';
  String _v2 = '';
  String _v3 = '';
  String _v4 = '';
  String _manual = '';

  Future<TimeOfDay?> _pick() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  Widget _field({
    required String value,
    required String placeholder,
    required ValueChanged<String> onPick,
    double width = 168,
    IconData icon = Icons.access_time,
  }) {
    return InkWell(
      onTap: () async {
        final t = await _pick();
        if (t != null) {
          onPick('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        width: width,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDCDEE2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF808695)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value.isEmpty ? placeholder : value,
                style: TextStyle(
                  fontSize: 12,
                  color: value.isEmpty
                      ? AppColors.textPlaceholder
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description:
              '设置属性 type 为 time 或 timerange 分别显示选择单个时间和选择范围时间类型。设置属性 placement 可以更改选择器出现的方向。',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _field(
                value: _v1,
                placeholder: '选择时间',
                onPick: (v) => setState(() => _v1 = v),
              ),
              _field(
                value: _v2,
                placeholder: '选择时间',
                onPick: (v) => setState(() => _v2 = v),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '选择时分',
          description: '组件浮层中的列会随着 format 变化, 当略去 format 中的秒时, 浮层中对应的列也会消失。',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _field(
                width: 112,
                value: _v3,
                placeholder: '选择时间',
                onPick: (v) => setState(() => _v3 = v),
              ),
              _field(
                value: _v4,
                placeholder: '选择时间',
                onPick: (v) => setState(() => _v4 = v),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '不可选时间',
          description:
              '可以使用 disabled-hours, disabled-minutes, disabled-seconds 组合禁止用户选择某个时间。使用 hide-disabled-options 可以直接把不可选择的项隐藏。',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _field(
                value: '',
                placeholder: '选择时间',
                onPick: (_) {},
              ),
              _field(
                value: '',
                placeholder: '选择时间',
                onPick: (_) {},
              ),
            ],
          ),
        ),
        DemoSection(
          title: '手动控制组件',
          description: '对于一些定制化的场景, 可以使用 slot 配合参数 open confirm 及事件来手动控制组件的显示状态。',
          child: InkWell(
            onTap: () async {
              final t = await _pick();
              if (t != null) {
                setState(() => _manual =
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  _manual.isEmpty ? '选择时间' : _manual,
                  style: const TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Upload ─────────────────────────

class UploadDemo extends StatefulWidget {
  const UploadDemo({super.key});
  @override
  State<UploadDemo> createState() => _UploadDemoState();
}

class _UploadDemoState extends State<UploadDemo> {
  final _files1 = <String>[];
  final _files2 = <String>[];
  @override
  Widget build(BuildContext context) {
    Widget uploadButton(VoidCallback onTap) => OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.cloud_upload_outlined, size: 16),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: Color(0xFFDDDEE1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          label: const Text('上传文件'),
        );

    Widget fileList(List<String> files) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final f in files)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(f, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => files.remove(f)),
                      child: const Icon(Icons.close,
                          size: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        );

    return _DemoPage(
      children: [
        DemoSection(
          title: '基础用法',
          description: '通过设置属性 action 为上传的地址即可。最简单的用法是: 选择文件后立即上传, 并显示文件列表。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uploadButton(() {
                setState(() {
                  _files1.add('file-${_files1.length + 1}.png');
                });
              }),
              const SizedBox(height: 6),
              fileList(_files1),
            ],
          ),
        ),
        DemoSection(
          title: '多文件上传',
          description: '通过设置属性 multiple, 一次可以选择多个文件上传。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uploadButton(() {
                setState(() {
                  // simulate selecting 3 at once
                  for (var i = 0; i < 3; i++) {
                    _files2.add('file-${_files2.length + 1}.png');
                  }
                });
              }),
              const SizedBox(height: 6),
              fileList(_files2),
            ],
          ),
        ),
      ],
    );
  }
}

class DottedBorder extends StatelessWidget {
  const DottedBorder({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderBase
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + dashWidth, size.height),
        paint,
      );
      x += dashWidth + dashSpace;
    }
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashWidth), paint);
      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width, y + dashWidth),
        paint,
      );
      y += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
