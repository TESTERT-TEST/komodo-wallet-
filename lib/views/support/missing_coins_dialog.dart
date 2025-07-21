import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/coins_bloc/coins_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_events_factory.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_wrapper.dart';
import 'package:app_theme/app_theme.dart';

Future<void> showMissingCoinsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      content: _buildDialogContent(context),
      title: Text(LocaleKeys.myCoinsMissing.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.close.tr()),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();

            _launchHelpUrl();
          },
          child: Text(LocaleKeys.myCoinsMissingMoreInfo.tr()),
        ),
      ],
    ),
  );
}

Widget _buildDialogContent(BuildContext context) {
  final theme = Theme.of(context);
  final textStyle = theme.textTheme.bodyMedium;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(LocaleKeys.myCoinsMissingReassurance.tr(), style: textStyle),
      const SizedBox(height: 8),
      Text(
        // "To recover:"
        LocaleKeys.myCoinsMissingToRecover.tr(),
        style: textStyle?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        // "Log out → Turn OFF \"Multi Address Wallet\" → Log in → Add your coins back"
        LocaleKeys.myCoinsMissingSteps.tr(),
        style: textStyle,
      ),
    ],
  );
}

Future<void> _launchHelpUrl() async {
  final url = Uri.parse(
      'https://komodoplatform.com/en/blog/komodo-wallet-v0-9-0-is-now-live/#note-for-web-wallet-users-with-existing-wallets-before-the-latest-release');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}
