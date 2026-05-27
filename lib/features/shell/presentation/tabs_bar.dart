import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/tabs_controller.dart';

class TabsBar extends ConsumerWidget {
  const TabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabsControllerProvider);
    final controller = ref.read(tabsControllerProvider.notifier);

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemCount: state.items.length,
              itemBuilder: (_, i) {
                final t = state.items[i];
                final active = t.key == state.activeKey;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: _TabChip(
                    label: t.title,
                    active: active,
                    closable: t.closable,
                    onTap: () {
                      controller.activate(t.key);
                      GoRouter.of(context).go(t.path);
                    },
                    onClose: () {
                      final next = controller.close(t.key);
                      if (next != null) {
                        GoRouter.of(context).go(next);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            icon: const Icon(Icons.more_horiz),
            onSelected: (v) {
              if (v == 'closeOthers' && state.activeKey != null) {
                controller.closeOthers(state.activeKey!);
              } else if (v == 'closeAll') {
                final next = controller.closeAll();
                if (next != null) GoRouter.of(context).go(next);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'closeOthers', child: Text('关闭其它')),
              PopupMenuItem(value: 'closeAll', child: Text('关闭全部')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.closable,
    required this.onTap,
    required this.onClose,
  });

  final String label;
  final bool active;
  final bool closable;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: active ? AppColors.primary : AppColors.textRegular,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (closable) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
