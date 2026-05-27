import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/charts/charts_page.dart';
import '../../features/components/component_demos.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/editor_markdown/markdown_editor_page.dart';
import '../../features/errors/error_pages.dart';
import '../../features/introduction/introduction_page.dart';
import '../../features/json_view/json_view_page.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/table/table_page.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final repo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final loggedIn = await repo.isLoggedIn();
      final goingToLogin = loc == AppRoutes.login;

      if (!loggedIn && !goingToLogin) {
        final from = Uri.encodeQueryComponent(loc);
        return '${AppRoutes.login}?from=$from';
      }
      if (loggedIn && goingToLogin) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (ctx, state) => LoginPage(
          redirect: state.uri.queryParameters['from'],
        ),
      ),
      ShellRoute(
        builder: (ctx, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', redirect: (_, __) => AppRoutes.dashboard),
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.introduction,
            builder: (_, __) => const IntroductionPage(),
          ),
          GoRoute(
            path: '/charts/:type',
            name: 'chart',
            builder: (_, s) => ChartsPage(type: s.pathParameters['type']!),
          ),
          GoRoute(
            path: '/charts',
            redirect: (_, __) => AppRoutes.chartShop,
          ),
          GoRoute(
            path: AppRoutes.markdown,
            builder: (_, __) => const MarkdownEditorPage(),
          ),
          GoRoute(
            path: AppRoutes.jsonTree,
            builder: (_, __) => const JsonViewPage(),
          ),
          GoRoute(
            path: AppRoutes.table,
            builder: (_, __) => const TablePage(),
          ),
          GoRoute(
            path: AppRoutes.compButtons,
            builder: (_, __) => const ButtonsDemo(),
          ),
          GoRoute(
            path: AppRoutes.compHoverButtons,
            builder: (_, __) => const HoverButtonsDemo(),
          ),
          GoRoute(
            path: AppRoutes.compAlert,
            builder: (_, __) => const AlertDemo(),
          ),
          GoRoute(
            path: AppRoutes.compCard,
            builder: (_, __) => const CardDemo(),
          ),
          GoRoute(
            path: AppRoutes.compDatePicker,
            builder: (_, __) => const DatePickerDemo(),
          ),
          GoRoute(
            path: AppRoutes.compForm,
            builder: (_, __) => const FormDemo(),
          ),
          GoRoute(
            path: AppRoutes.compModal,
            builder: (_, __) => const ModalDemo(),
          ),
          GoRoute(
            path: AppRoutes.compSelect,
            builder: (_, __) => const SelectDemo(),
          ),
          GoRoute(
            path: AppRoutes.compSpin,
            builder: (_, __) => const SpinDemo(),
          ),
          GoRoute(
            path: AppRoutes.compSteps,
            builder: (_, __) => const StepsDemo(),
          ),
          GoRoute(
            path: AppRoutes.compTimeline,
            builder: (_, __) => const TimelineDemo(),
          ),
          GoRoute(
            path: AppRoutes.compTransfer,
            builder: (_, __) => const TransferDemo(),
          ),
          GoRoute(
            path: AppRoutes.compTimepicker,
            builder: (_, __) => const TimepickerDemo(),
          ),
          GoRoute(
            path: AppRoutes.compUpload,
            builder: (_, __) => const UploadDemo(),
          ),
        ],
      ),
      // Error pages live OUTSIDE the shell — matches Vue's `/pages/*` routes
      // which use a `<router-view/>` container (no Full layout).
      GoRoute(
        path: AppRoutes.error401,
        builder: (_, __) => const ErrorPage(code: 401),
      ),
      GoRoute(
        path: AppRoutes.error403,
        builder: (_, __) => const ErrorPage(code: 403),
      ),
      GoRoute(
        path: AppRoutes.error404,
        builder: (_, __) => const ErrorPage(code: 404),
      ),
      GoRoute(
        path: AppRoutes.error500,
        builder: (_, __) => const ErrorPage(code: 500),
      ),
    ],
    errorBuilder: (_, state) => const ErrorPage(code: 404),
  );
});
