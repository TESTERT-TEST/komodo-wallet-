import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/bridge_form/bridge_bloc.dart';
import 'package:web_dex/bloc/bridge_form/bridge_event.dart';
import 'package:web_dex/bloc/taker_form/taker_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_event.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/views/dex/dex_helpers.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_events_factory.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_wrapper.dart';

class ConnectWalletButton extends StatefulWidget {
  const ConnectWalletButton({
    Key? key,
    required this.eventType,
    this.withText = true,
    this.withIcon = false,
    Size? buttonSize,
  })  : buttonSize = buttonSize ?? const Size(double.infinity, 40),
        super(key: key);
  final Size buttonSize;
  final bool withIcon;
  final bool withText;
  final WalletsManagerEventType eventType;

  @override
  State<ConnectWalletButton> createState() => _ConnectWalletButtonState();
}

class _ConnectWalletButtonState extends State<ConnectWalletButton> {
  static const String walletIconPath =
      '$assetsPath/nav_icons/desktop/dark/wallet.svg';

  PopupDispatcher? _popupDispatcher;

  @override
  void dispose() {
    _popupDispatcher?.close();
    _popupDispatcher = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.withText
        ? UiPrimaryButton(
            key: Key('connect-wallet-${widget.eventType.name}'),
            width: widget.buttonSize.width,
            height: widget.buttonSize.height,
            prefix: widget.withIcon
                ? Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: SvgPicture.asset(
                      walletIconPath,
                      colorFilter: ColorFilter.mode(
                          theme.custom.defaultGradientButtonTextColor,
                          BlendMode.srcIn),
                      width: 15,
                      height: 15,
                    ),
                  )
                : null,
            text: LocaleKeys.connectSomething
                .tr(args: [LocaleKeys.wallet.tr().toLowerCase()]),
            onPressed: onButtonPressed,
          )
        : ElevatedButton(
            key: Key('connect-wallet-${widget.eventType.name}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.currentGlobal.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            onPressed: onButtonPressed,
            child: SvgPicture.asset(
              walletIconPath,
              colorFilter: ColorFilter.mode(
                  theme.custom.defaultGradientButtonTextColor, BlendMode.srcIn),
              width: 20,
            ),
          );
  }

  void onButtonPressed() {
    _popupDispatcher = _createPopupDispatcher();
    _popupDispatcher?.show();
  }

  PopupDispatcher _createPopupDispatcher() {
    final TakerBloc takerBloc = context.read<TakerBloc>();
    final BridgeBloc bridgeBloc = context.read<BridgeBloc>();

    return PopupDispatcher(
      borderColor: theme.custom.specificButtonBorderColor,
      barrierColor: isMobile ? Theme.of(context).colorScheme.onSurface : null,
      width: 320,
      context: scaffoldKey.currentContext ?? context,
      popupContent: WalletsManagerWrapper(
        eventType: widget.eventType,
        onSuccess: (_) async {
          takerBloc.add(TakerReInit());
          bridgeBloc.add(const BridgeReInit());
          await reInitTradingForms(context);
          _popupDispatcher?.close();
        },
      ),
    );
  }
}
