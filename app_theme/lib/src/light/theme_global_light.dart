import 'package:flutter/material.dart';
import 'theme_custom_light.dart';

ThemeData get themeGlobalLight {
  const Color inputBackgroundColor = Color.fromRGBO(243, 245, 246, 1);
  const Color textColor = Color.fromRGBO(69, 96, 120, 1);

  OutlineInputBorder outlineBorderLight(Color lightAccentColor) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: lightAccentColor),
        borderRadius: BorderRadius.circular(12),
      );

  final ColorScheme colorScheme = const ColorScheme.light().copyWith(
    primary: const Color(0xFF14B88F), // Changed to rgb(20, 184, 143)
    secondary: const Color(0xFF4ADE80), // Changed to rgb(74, 222, 128)
    tertiary: const Color.fromARGB(255, 222, 255, 236), // Changed to light green
    surface: const Color.fromRGBO(255, 255, 255, 1),
    onSurface: const Color.fromRGBO(251, 251, 251, 1),
    error: const Color.fromRGBO(229, 33, 103, 1),
  );

  final TextTheme textTheme = TextTheme(
    headlineMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    headlineSmall: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    titleLarge: const TextStyle(
      fontSize: 26.0,
      color: textColor,
      fontWeight: FontWeight.w700,
    ),
    titleSmall: const TextStyle(fontSize: 18.0, color: textColor),
    bodyMedium: const TextStyle(
      fontSize: 16.0,
      color: textColor,
      fontWeight: FontWeight.w300,
    ),
    labelLarge: const TextStyle(fontSize: 16.0, color: textColor),
    bodyLarge: TextStyle(
      fontSize: 14.0,
      color: textColor.withAlpha(128),
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      color: textColor.withAlpha(204),
      fontWeight: FontWeight.w400,
    ),
  );

  SnackBarThemeData snackBarThemeLight() => SnackBarThemeData(
        elevation: 12.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        actionTextColor: colorScheme.onPrimaryContainer,
        showCloseIcon: true,
        closeIconColor: colorScheme.onPrimaryContainer.withAlpha(179),
      );

  final customTheme = ThemeCustomLight();
  final theme = ThemeData(
    useMaterial3: false,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: colorScheme.onSurface,
    cardColor: colorScheme.surface,
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    dividerColor: const Color.fromRGBO(208, 214, 237, 1),
    appBarTheme: AppBarTheme(color: colorScheme.surface),
    iconTheme: IconThemeData(color: colorScheme.primary),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    canvasColor: colorScheme.surface,
    hintColor: const Color.fromRGBO(183, 187, 191, 1),
    snackBarTheme: snackBarThemeLight(),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xFF14B88F), // Changed to rgb(20, 184, 143)
      selectionColor: const Color(0xFF14B88F).withAlpha(77), // Changed to rgb(20, 184, 143)
      selectionHandleColor: const Color(0xFF14B88F), // Changed to rgb(20, 184, 143)
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: outlineBorderLight(Colors.transparent),
      disabledBorder: outlineBorderLight(Colors.transparent),
      border: outlineBorderLight(Colors.transparent),
      focusedBorder: outlineBorderLight(Colors.transparent),
      errorBorder: outlineBorderLight(colorScheme.error),
      fillColor: inputBackgroundColor,
      focusColor: inputBackgroundColor,
      hoverColor: Colors.transparent,
      errorStyle: TextStyle(color: colorScheme.error),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      hintStyle: TextStyle(
        color: textColor.withAlpha(148),
      ),
      labelStyle: TextStyle(
        color: textColor.withAlpha(148),
      ),
      prefixIconColor: textColor.withAlpha(148),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) return Colors.grey;
          return colorScheme.primary;
        }),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
      fillColor: WidgetStateProperty.all<Color>(colorScheme.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
    ),
    textTheme: textTheme,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all<Color?>(
        colorScheme.primary.withAlpha(204),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: const Color(0xFF14B88F), // Changed to rgb(20, 184, 143)
      unselectedItemColor: textColor,
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return const Color(0xFFD1D1D1);
        },
      ),
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.white;
        },
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(243, 245, 246, 1),
        surfaceTintColor: Colors.purple,
        selectedBackgroundColor: colorScheme.primary,
        foregroundColor: textColor.withAlpha(179),
        selectedForegroundColor: Colors.white,
        side: const BorderSide(color: Color.fromRGBO(208, 214, 237, 1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: textColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.0, color: colorScheme.primary),
        insets: const EdgeInsets.symmetric(horizontal: 18),
      ),
    ),
    extensions: [customTheme],
  );

  customTheme.initializeThemeDependentColors(theme);

  return theme;
}