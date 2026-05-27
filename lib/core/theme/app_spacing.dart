class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 999;
}

class AppBreakpoints {
  const AppBreakpoints._();

  static const double sm = 600;
  static const double md = 1024;
  static const double lg = 1440;

  static bool isSmall(double width) => width < sm;
  static bool isMedium(double width) => width >= sm && width < md;
  static bool isLarge(double width) => width >= md;
}
