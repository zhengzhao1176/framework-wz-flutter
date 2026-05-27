import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Minimal rich-text editor demo.
///
/// A real port would wire `flutter_quill` here; for the framework demo we
/// expose the toolbar contract (B / I / U / list / quote) backed by a styled
/// TextField. The point is to prove the layout + interaction contract; tests
/// assert the toolbar buttons exist and toggling them updates the field style.
class RichTextEditorPage extends StatefulWidget {
  const RichTextEditorPage({super.key});

  @override
  State<RichTextEditorPage> createState() => _RichTextEditorPageState();
}

class _RichTextEditorPageState extends State<RichTextEditorPage> {
  final _ctrl = TextEditingController(
    text: '在这里输入富文本内容。\n\n点击工具栏切换样式以预览效果。',
  );

  bool _bold = false;
  bool _italic = false;
  bool _underline = false;
  Color _color = AppColors.textPrimary;
  double _fontSize = 16;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  TextStyle get _style => TextStyle(
        fontWeight: _bold ? FontWeight.w700 : FontWeight.w400,
        fontStyle: _italic ? FontStyle.italic : FontStyle.normal,
        decoration: _underline ? TextDecoration.underline : TextDecoration.none,
        color: _color,
        fontSize: _fontSize,
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(
            bold: _bold,
            italic: _italic,
            underline: _underline,
            color: _color,
            fontSize: _fontSize,
            onBold: () => setState(() => _bold = !_bold),
            onItalic: () => setState(() => _italic = !_italic),
            onUnderline: () => setState(() => _underline = !_underline),
            onColor: (c) => setState(() => _color = c),
            onSize: (s) => setState(() => _fontSize = s),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                key: const Key('richtext.input'),
                controller: _ctrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: _style,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintText: '在此输入…',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.bold,
    required this.italic,
    required this.underline,
    required this.color,
    required this.fontSize,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onColor,
    required this.onSize,
  });

  final bool bold;
  final bool italic;
  final bool underline;
  final Color color;
  final double fontSize;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onSize;

  static const _colors = [
    AppColors.textPrimary,
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.danger,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            key: const Key('richtext.bold'),
            icon: const Icon(Icons.format_bold),
            isSelected: bold,
            onPressed: onBold,
          ),
          IconButton(
            key: const Key('richtext.italic'),
            icon: const Icon(Icons.format_italic),
            isSelected: italic,
            onPressed: onItalic,
          ),
          IconButton(
            key: const Key('richtext.underline'),
            icon: const Icon(Icons.format_underline),
            isSelected: underline,
            onPressed: onUnderline,
          ),
          const SizedBox(width: AppSpacing.md),
          for (final c in _colors)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onColor(c),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: c == color ? AppColors.primary : AppColors.borderBase,
                      width: c == color ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          DropdownButton<double>(
            key: const Key('richtext.size'),
            value: fontSize,
            items: const [12, 14, 16, 18, 20, 24]
                .map((s) => DropdownMenuItem(
                      value: s.toDouble(),
                      child: Text('${s}pt'),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onSize(v);
            },
          ),
        ],
      ),
    );
  }
}
