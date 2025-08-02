import 'package:flutter/material.dart';

import '../common/theme_custom_base.dart';

class ThemeCustomDark extends ThemeExtension<ThemeCustomDark>
    implements ThemeCustomBase {
  ThemeCustomDark();

  @override
  late final Color suspendedBannerBackgroundColor;

  void initializeThemeDependentColors(ThemeData theme) {
    suspendedBannerBackgroundColor = theme.colorScheme.onSurface;
  }

  @override
  ThemeExtension<ThemeCustomDark> copyWith() {
    return this;
  }

  @override
  ThemeExtension<ThemeCustomDark> lerp(
      ThemeExtension<ThemeCustomDark>? other, double t) {
    if (other is! ThemeCustomDark) return this;
    return this;
  }

  @override
  final Color mainMenuItemColor = const Color.fromRGBO(173, 198, 175, 1); // зелено-серый
  @override
  final Color mainMenuSelectedItemColor = Colors.white;
  @override
  final Color checkCheckboxColor = Colors.white;
  @override
  final Color borderCheckboxColor = const Color.fromRGBO(62, 99, 70, 1); // тёмно-зелёный
  @override
  final TextStyle tradingFormDetailsLabel = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  @override
  final TextStyle tradingFormDetailsContent = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color.fromRGBO(74, 222, 128, 1),
  );
  @override
  final Color fiatAmountColor = const Color.fromRGBO(168, 185, 177, 1);
  @override
  final Color headerFloatBoxColor = const Color.fromRGBO(20, 184, 143, 1);
  @override
  final Color headerIconColor = const Color.fromRGBO(255, 255, 255, 1);
  @override
  final Color buttonColorDefault = const Color.fromRGBO(23, 29, 48, 1);
  @override
  final Color buttonColorDefaultHover = const Color.fromRGBO(20, 184, 143, 1);
  @override
  final Color buttonTextColorDefaultHover =
      const Color.fromRGBO(245, 249, 255, 1);
  @override
  final Color noColor = Colors.transparent;
  @override
  final Color increaseColor = const Color(0xFF14B88F);
  @override
  final Color decreaseColor = const Color.fromRGBO(229, 33, 103, 1);
  @override
  final Color zebraDarkColor = const Color(0xFF0F0F0F);
  @override
  final Color zebraLightColor = const Color(0xFF141414);
  @override
  final Color zebraHoverColor = const Color(0xFF1A1A1A);
  @override
  final Color passwordButtonSuccessColor =
      const Color.fromRGBO(74, 222, 128, 1);
  @override
  final Color simpleButtonBackgroundColor =
      const Color.fromRGBO(20, 184, 143, 0.2);
  @override
  final Color disabledButtonBackgroundColor =
      const Color.fromRGBO(20, 184, 143, 0.3);
  @override
  final Gradient authorizePageBackgroundColor = const RadialGradient(
    center: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(20, 184, 143, 0.1),
      Color.fromRGBO(20, 184, 143, 0),
    ],
  );
  @override
  final Color authorizePageLineColor = const Color.fromRGBO(255, 255, 255, 0.1);
  @override
  final Color defaultGradientButtonTextColor = Colors.white;
  @override
  final Color defaultCheckboxColor = const Color.fromRGBO(20, 184, 143, 1);
  @override
  final Gradient defaultSwitchColor = const LinearGradient(
    stops: [0, 93],
    colors: [Color(0xFF14B88F), Color(0xFF4ADE80)],
  );
  @override
  final Color settingsMenuItemBackgroundColor = const Color(0xFF141414);
  @override
  final Gradient userRewardBoxColor = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.fromRGBO(18, 20, 32, 1), Color.fromRGBO(22, 25, 39, 1)],
      stops: [0.05, 0.33]);
  @override
  final Color rewardBoxShadowColor = const Color.fromRGBO(0, 0, 0, 0.1);
  @override
  final Color defaultBorderButtonBorder = const Color(0xFF4ADE80);
  @override
  final Color defaultBorderButtonBackground =
      const Color.fromRGBO(13, 54, 6, 1);
  @override
  final Color successColor = const Color.fromRGBO(0, 192, 88, 1);
  @override
  final Color defaultCircleButtonBackground =
      const Color.fromRGBO(222, 235, 200, 0.56);
  @override
  final TradingDetailsTheme tradingDetailsTheme = const TradingDetailsTheme();
  @override
  final Color protocolTypeColor = const Color(0xfffcbb80);
  @override
  final CoinsManagerTheme coinsManagerTheme = const CoinsManagerTheme(
    searchFieldMobileBackgroundColor: Color(0xFF1A1A1A),
    filtersPopupShadow: BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 8,
      color: Color.fromRGBO(0, 0, 0, 0.3),
    ),
    filterPopupItemBorderColor: Color(0xFF4ADE80),
  );
  @override
  final DexPageTheme dexPageTheme = const DexPageTheme(
    activeOrderFormTabColor: Color.fromRGBO(255, 255, 255, 1),
    inactiveOrderFormTabColor: Color.fromRGBO(152, 182, 155, 1), // заменён на зелёный
    activeOrderFormTab: Color.fromRGBO(255, 255, 255, 1),
    inactiveOrderFormTab: Color.fromRGBO(152, 182, 155, 1),
    formPlateGradient: LinearGradient(
      colors: [
        Color.fromRGBO(20, 184, 143, 1),
        Color.fromRGBO(255, 165, 0, 1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    frontPlate: Color.fromRGBO(32, 55, 35, 1),
    frontPlateInner: Color.fromRGBO(21, 33, 25, 1),
    frontPlateBorder: Color.fromRGBO(43, 87, 49, 1),
    activeText: Colors.white,
    inactiveText: Color.fromRGBO(123, 152, 131, 1),
    blueText: Color.fromRGBO(74, 222, 128, 1),
    smallButton: Color.fromRGBO(35, 72, 39, 1),
    smallButtonText: Color.fromRGBO(141, 167, 150, 1),
    pagePlateDivider: Color.fromRGBO(32, 63, 37, 1),
    coinPlateDivider: Color.fromRGBO(44, 81, 51, 1),
    formPlateDivider: Color.fromRGBO(48, 96, 57, 1),
    emptyPlace: Color.fromRGBO(40, 69, 44, 1),
    tokenName: Color.fromRGBO(69, 120, 96, 1),
    expandMore: Color.fromRGBO(153, 181, 168, 1),
  );
  @override
  final Color asksColor = const Color(0xffe52167);
  @override
  final Color bidsColor = const Color(0xFF14B88F);
  @override
  final Color targetColor = Colors.orange;
  @override
  final double dexFormWidth = 480;
  @override
  final double dexInputWidth = 320;
  @override
  final Color specificButtonBorderColor = const Color.fromRGBO(38, 52, 40, 1);
  @override
  final Color specificButtonBackgroundColor = const Color(0xFF141414);
  @override
  final Color balanceColor = const Color.fromRGBO(74, 222, 128, 1);
  @override
  final Color subBalanceColor = const Color.fromRGBO(124, 171, 136, 1);
  @override
  final Color subCardBackgroundColor = const Color(0xFF0F0F0F);
  @override
  final Color lightButtonColor = const Color.fromRGBO(20, 184, 143, 0.12);
  @override
  final Color filterItemBorderColor = const Color.fromRGBO(52, 77, 56, 1);
  @override
  final Color warningColor = const Color.fromRGBO(229, 33, 103, 1);
  @override
  final Color progressBarColor = const Color.fromRGBO(69, 120, 96, 0.33);
  @override
  final Color progressBarPassedColor = const Color.fromRGBO(74, 222, 128, 1);
  @override
  final Color progressBarNotPassedColor =
      const Color.fromRGBO(194, 210, 203, 1);
  @override
  final Color dexSubTitleColor = const Color.fromRGBO(255, 255, 255, 1);
  @override
  final Color selectedMenuBackgroundColor =
      const Color.fromRGBO(46, 112, 52, 1);
  @override
  final Color tabBarShadowColor = const Color.fromRGBO(255, 255, 255, 0.08);
  @override
  final Color smartchainLabelBorderColor =
      const Color.fromRGBO(32, 49, 22, 1);
  @override
  final Color mainMenuSelectedItemBackgroundColor =
      const Color.fromRGBO(20, 184, 143, 0.12);
  @override
  final Color searchFieldMobile = const Color.fromRGBO(42, 62, 47, 1);
  @override
  final Color walletEditButtonsBackgroundColor =
      const Color.fromRGBO(29, 53, 33, 1);
  @override
  final Color swapButtonColor = const Color.fromRGBO(20, 184, 143, 1);
  @override
  final bridgeFormHeader = const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 3.5);
  @override
  final Color keyPadColor = const Color(0xFF000000);
  @override
  final Color keyPadTextColor = const Color.fromRGBO(129, 182, 151, 1);
  @override
  final Color dexCoinProtocolColor = const Color.fromRGBO(168, 185, 177, 1);
  @override
  final Color dialogBarrierColor = const Color.fromRGBO(3, 26, 43, 0.36);
  @override
  final Color noTransactionsTextColor = const Color.fromRGBO(196, 196, 196, 1);
}
