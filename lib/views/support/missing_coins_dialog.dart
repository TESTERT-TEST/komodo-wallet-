import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_theme/app_theme.dart';

import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/coins_bloc/coins_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_events_factory.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_wrapper.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/shared/widgets/html_parser.dart';

Future<void> showMissingCoinsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(LocaleKeys.myCoinsMissing.tr()),
      content: HtmlParser(
        LocaleKeys.myCoinsMissingDialogContent.tr(),
        linkStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.myCoinsMissingHelp.tr()),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _signInSingleAddressMode(context);
          },
          child: Text(LocaleKeys.myCoinsMissingSignIn.tr()),
        ),
      ],
    ),
  );
}

Future<void> _signInSingleAddressMode(BuildContext context) async {
  final wallet = context.read<AuthBloc>().state.currentUser?.wallet;
  context.read<CoinsBloc>().add(CoinsSessionEnded());
  context.read<AuthBloc>().add(const AuthSignOutRequested());
  await context
      .read<AuthBloc>()
      .stream
      .firstWhere((s) => s.mode == AuthorizeMode.noLogin);
  if (!context.mounted) return;
  final flutterTheme = Theme.of(context);
  PopupDispatcher(
    context: scaffoldKey.currentContext ?? context,
    width: 320,
    barrierColor: isMobile ? flutterTheme.colorScheme.onSurface : null,
    borderColor: theme.custom.specificButtonBorderColor,
    popupContent: WalletsManagerWrapper(
      eventType: WalletsManagerEventType.header,
      selectedWallet: wallet,
      initialHdMode: false,
    ),
  ).show();
}
