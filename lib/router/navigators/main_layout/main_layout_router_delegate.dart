import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/router/navigators/page_content/page_content_router.dart';
import 'package:web_dex/router/navigators/page_menu/page_menu_router.dart';
import 'package:web_dex/router/routes.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/views/common/main_menu/main_menu_desktop.dart';
import 'package:web_dex/bloc/coins_bloc/coins_bloc.dart';
import 'package:web_dex/bloc/coins_bloc/asset_coin_extension.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/formatters.dart';
import 'package:web_dex/views/common/header/actions/account_switcher.dart';
import 'package:web_dex/release_options.dart';
import 'package:web_dex/shared/utils/extensions/sdk_extensions.dart';

class MainLayoutRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      switch (screenType) {
        case ScreenType.mobile:
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxScreenWidth,
              ),
              child: _MobileLayout(),
            ),
          );
        case ScreenType.tablet:
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxScreenWidth,
              ),
              child: _TabletLayout(),
            ),
          );
        case ScreenType.desktop:
          return _DesktopLayout();
      }
    });
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {}
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-height drawer sidebar
        Container(
          width: 280, // Fixed width for the sidebar
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: MainMenuDesktop(),
        ),
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Top header bar with actions
              Container(
                // height: appBarHeight,
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: AppBar(
                  toolbarHeight: appBarHeight,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  // backgroundColor: Colors.transparent,
                  leading: BlocBuilder<CoinsBloc, CoinsState>(
                    builder: (context, state) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: ActionTextButton(
                          text: LocaleKeys.balance.tr(),
                          secondaryText:
                              '\$${formatAmt(_getTotalBalance(state.walletCoins.values, context))}',
                          onTap: null,
                        ),
                      );
                    },
                  ),
                  leadingWidth: 200, // Give more space for the balance text
                  actions: _getOtherHeaderActions(context),
                  titleSpacing: 0,
                ),
              ),
              // Main content
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, mainLayoutPadding, 0),
                  child: PageContentRouter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: PageContentRouter()),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: routingState.isPageContentShown
              ? PageContentRouter()
              : PageMenuRouter(),
        ),
      ],
    );
  }
}

// Helper functions for header layout
double _getTotalBalance(Iterable<Coin> coins, BuildContext context) {
  double total =
      coins.fold(0, (prev, coin) => prev + (coin.usdBalance(context.sdk) ?? 0));

  if (total > 0.01) {
    return total;
  }

  return total != 0 ? 0.01 : 0;
}

List<Widget> _getOtherHeaderActions(BuildContext context) {
  final languageCodes = localeList.map((e) => e.languageCode).toList();
  final langCode2flags = {
    for (var loc in languageCodes)
      loc: SvgPicture.asset(
        '$assetsPath/flags/$loc.svg',
      ),
  };

  return [
    Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (showLanguageSwitcher) ...[
          LanguageSwitcher(
            currentLocale: context.locale.toString(),
            languageCodes: languageCodes,
            flags: langCode2flags,
          ),
          SizedBox(width: 16),
        ],
        Container(
          height: 40,
          child: AccountSwitcher(),
        ),
      ]),
    )
  ];
}
