import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({super.key});

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  late final TextEditingController _ctrl;

  static const _sample = '''
# 欢迎使用 Markdown 编辑器

支持常规 **粗体**、*斜体*、`code` 与 [链接](https://flutter.dev)。

## 列表
- 苹果
- 香蕉
- 橘子

## 代码块
```dart
void main() {
  print('Hello, world!');
}
```

## 引用
> 测试驱动交付。

---

可在左侧实时编辑，右侧预览。
''';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _sample);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth >= 800;
        final editor = _EditorPane(controller: _ctrl);
        final preview = _PreviewPane(controller: _ctrl);
        const header = Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '超赞的👍 ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: 'mavonEditor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ]),
            ),
          ),
        );
        if (wide) {
          return Column(
            children: [
              header,
              Expanded(
                child: Card(
                  child: Row(
                    children: [
                      Expanded(child: editor),
                      const VerticalDivider(width: 1),
                      Expanded(child: preview),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            header,
            Expanded(
              child: Card(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [Tab(text: '编辑'), Tab(text: '预览')],
                      ),
                      Expanded(
                        child: TabBarView(children: [editor, preview]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({required this.controller});
  final TextEditingController controller;

  void _wrap(String l, String r) {
    final sel = controller.selection;
    if (!sel.isValid) return;
    final text = controller.text;
    final selected = sel.textInside(text);
    final newText = text.replaceRange(sel.start, sel.end, '$l$selected$r');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: sel.start + l.length + selected.length + r.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          // Toolbar mirrors mavonEditor's left+right groups.
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold, size: 18),
                tooltip: '加粗',
                onPressed: () => _wrap('**', '**'),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic, size: 18),
                tooltip: '斜体',
                onPressed: () => _wrap('*', '*'),
              ),
              IconButton(
                icon: const Icon(Icons.title, size: 18),
                tooltip: '标题',
                onPressed: () => _wrap('## ', ''),
              ),
              IconButton(
                icon: const Icon(Icons.format_underline, size: 18),
                tooltip: '下划线',
                onPressed: () => _wrap('<u>', '</u>'),
              ),
              IconButton(
                icon: const Icon(Icons.strikethrough_s, size: 18),
                tooltip: '删除线',
                onPressed: () => _wrap('~~', '~~'),
              ),
              IconButton(
                icon: const Icon(Icons.format_quote, size: 18),
                tooltip: '引用',
                onPressed: () => _wrap('> ', ''),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_numbered, size: 18),
                tooltip: '有序列表',
                onPressed: () => _wrap('1. ', ''),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted, size: 18),
                tooltip: '无序列表',
                onPressed: () => _wrap('- ', ''),
              ),
              IconButton(
                icon: const Icon(Icons.link, size: 18),
                tooltip: '链接',
                onPressed: () => _wrap('[', '](https://)'),
              ),
              IconButton(
                icon: const Icon(Icons.image_outlined, size: 18),
                tooltip: '图片',
                onPressed: () => _wrap('![](', ')'),
              ),
              IconButton(
                icon: const Icon(Icons.code, size: 18),
                tooltip: '代码',
                onPressed: () => _wrap('`', '`'),
              ),
              IconButton(
                icon: const Icon(Icons.table_chart_outlined, size: 18),
                tooltip: '表格',
                onPressed: () => _wrap('| 列1 | 列2 |\n| --- | --- |\n| ', ' |  |'),
              ),
              IconButton(
                icon: const Icon(Icons.undo, size: 18),
                tooltip: '撤销',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 18),
                tooltip: '重做',
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: '复制',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: controller.text));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制 Markdown')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, size: 18),
                tooltip: '帮助',
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              key: const Key('markdown.input'),
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Markdown(
          key: const Key('markdown.preview'),
          data: controller.text,
          selectable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
        );
      },
    );
  }
}
