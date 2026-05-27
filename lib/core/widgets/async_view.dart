import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Renders an [AsyncValue] in three canonical states: loading / error / data.
///
/// Matches TC convention from `task/04-test-plan.md` §5 — every async
/// surface goes through this so loading / error / empty are uniform.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.onRetry,
    this.loadingBuilder,
    this.emptyChecker,
    this.emptyBuilder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final VoidCallback? onRetry;
  final Widget Function()? loadingBuilder;
  final bool Function(T data)? emptyChecker;
  final Widget Function()? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loadingBuilder?.call() ?? const _LoadingView(),
      error: (e, _) => ErrorView(message: '$e', onRetry: onRetry),
      data: (data) {
        if (emptyChecker?.call(data) == true) {
          return emptyBuilder?.call() ?? const EmptyView();
        }
        return dataBuilder(data);
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = '暂无数据', this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textPlaceholder),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textRegular),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
