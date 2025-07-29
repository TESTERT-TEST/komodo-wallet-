import 'package:flutter/material.dart';

import '../../app_theme.dart';

const ColorSchemeExtension _colorSchemeExtension = ColorSchemeExtension(
  primary: Color(0xFF14B88F), // Changed to rgb(20, 184, 143)
  p50: Color(0xFF0E7D63), // Darker version of primary
  p40: Color(0xFF0B6450), // Even darker
  p10: Color(0xFF031A14), // Very dark version
  secondary: Color(0xFF4ADE80), // Changed to rgb(74, 222, 128)
  s70: Color.fromRGBO(121, 123, 137, 1),
  s50: Color.fromRGBO(87, 88, 98, 1),
  s40: Color.fromRGBO(69, 70, 78, 1),
  s30: Color.fromRGBO(52, 53, 59, 1),
  s20: Color.fromRGBO(35, 35, 39, 1),
  s10: Color.fromRGBO(17, 18, 20, 1),
  e10: Color.fromRGBO(21, 6, 10, 1),
  e20: Color.fromRGBO(42, 11, 21, 1),
  e50: Color.fromRGBO(105, 29, 52, 1),
  error: Color.fromRGBO(210, 57, 104, 1),
  g10: Color.fromRGBO(9, 19, 17, 1),
  g20: Color.fromRGBO(18, 38, 34, 1),
  green: Color.fromRGBO(88, 192, 171, 1),
  surf: Color.fromRGBO(255, 255, 255, 1),
  surfCont: Color(0xFF0A0A0A),
  surfContHigh: Color(0xFF141414),
  surfContHighest: Color(0xFF1A1A1A),
  surfContLow: Color(0xFF050505),
  surfContLowest: Color(0xFF000000),
  orange: Color.fromRGBO(237, 170, 70, 1),
  yellow: Color.fromRGBO(230, 188, 65, 1),
  purple: Color.fromRGBO(123, 73, 221, 1),
);

final ColorScheme _colorScheme = theme.global.dark.colorScheme.copyWith(
  primary: _colorSchemeExtension.primary,
  secondary: _colorSchemeExtension.secondary,
);
final TextTheme _textTheme = theme.global.dark.textTheme.copyWith();
final TextThemeExtension _textThemeExtension = TextThemeExtension(
  textColor: _colorSchemeExtension.secondary,
);

final ThemeData newThemeDataDark = theme.global.dark.copyWith(
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  inputDecorationTheme: theme.global.dark.inputDecorationTheme.copyWith(
    hintStyle: _textThemeExtension.bodySBold
        .copyWith(color: _colorSchemeExtension.s50),
    labelStyle: _textThemeExtension.bodyXSBold
        .copyWith(color: _colorSchemeExtension.primary),
    errorStyle:
        _textThemeExtension.bodyS.copyWith(color: _colorSchemeExtension.error),
    enabledBorder: _outlineBorderLight(_colorSchemeExtension.secondary),
    disabledBorder: _outlineBorderLight(_colorSchemeExtension.secondary),
    focusedBorder: _outlineBorderLight(_colorSchemeExtension.primary),
    errorBorder: _outlineBorderLight(_colorSchemeExtension.error),
    fillColor: Colors.transparent,
    hoverColor: Colors.transparent,
  ),
  extensions: [_colorSchemeExtension, _textThemeExtension],
);

OutlineInputBorder _outlineBorderLight(Color accentColor) => OutlineInputBorder(
      borderSide: BorderSide(color: accentColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    );