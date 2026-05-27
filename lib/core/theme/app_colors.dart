import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // iview Primary button = #2D8CF0
  static const Color primary = Color(0xFF2D8CF0);
  static const Color primaryDark = Color(0xFF2272D9);
  // iview defaults — match Vue's button colors:
  //   success #19BE6B, warning #FF9900, error #ED3F14, info #2DB7F5
  static const Color success = Color(0xFF19BE6B);
  static const Color warning = Color(0xFFFF9900);
  static const Color danger = Color(0xFFED3F14);
  static const Color info = Color(0xFF2DB7F5);

  // Background of the page content — matches Vue's `body` (#e4e5e6).
  static const Color bgPage = Color(0xFFE4E5E6);
  static const Color bgCard = Colors.white;
  // Sidebar: `.sidebar { background:#0d5477 }` from the original style.css.
  static const Color bgSidebar = Color(0xFF0D5477);
  static const Color bgSidebarHover = Color(0xFF143F6D);
  // Active item bg = `.nav-link.active { background:#20a8d8 }`.
  static const Color bgSidebarActive = Color(0xFF20A8D8);
  // Top-bar quick-action icons in iview source are all `#2d8cf0` (blue);
  // here we keep the variety we already had so they're distinguishable.
  static const Color quickMsg = Color(0xFF2D8CF0);
  static const Color quickBrowse = Color(0xFF2D8CF0);
  static const Color quickCloud = Color(0xFF2D8CF0);
  static const Color quickSales = Color(0xFF2D8CF0);

  // Body text in the original Vue CSS is #263238 (Material blue grey 900).
  static const Color textPrimary = Color(0xFF263238);
  static const Color textRegular = Color(0xFF455A64);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textPlaceholder = Color(0xFFB0BEC5);

  static const Color borderLight = Color(0xFFEBEEF5);
  static const Color borderBase = Color(0xFFDCDFE6);

  static const Color sidebarText = Color(0xFFB7BDC6);
  static const Color sidebarTextActive = Colors.white;
}
