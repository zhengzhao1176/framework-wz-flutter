/// Centralized route path constants. Mirror the original Vue project.
class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const introduction = '/introduction';

  // Component demos
  static const compButtons = '/components/buttons';
  static const compHoverButtons = '/components/hoverbuttons';
  static const compAlert = '/components/alert';
  static const compCard = '/components/card';
  static const compDatePicker = '/components/datepicker';
  static const compForm = '/components/form';
  static const compModal = '/components/modal';
  static const compSelect = '/components/select';
  static const compSpin = '/components/spin';
  static const compSteps = '/components/steps';
  static const compTimeline = '/components/timeline';
  static const compTransfer = '/components/transfer';
  static const compTimepicker = '/components/timepicker';
  static const compUpload = '/components/upload';

  // Charts
  static const chartShop = '/charts/shopchart';
  static const chartRadar = '/charts/radarchart';
  static const chartCake = '/charts/cakechart';
  static String chart(String type) => '/charts/$type';

  static const table = '/table';
  static const jsonTree = '/jsontree';
  static const markdown = '/markdown';

  static const error401 = '/pages/401';
  static const error403 = '/pages/403';
  static const error500 = '/pages/500';
  static const error404 = '/pages/404';
}
