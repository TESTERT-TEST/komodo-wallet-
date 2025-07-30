import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/trading_status/trading_status_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/shared/widgets/hidden_with_wallet.dart';
import 'package:web_dex/shared/widgets/hidden_without_wallet.dart';
import 'package:web_dex/views/settings/widgets/general_settings/import_swaps.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_download_logs.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_manage_analytics.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_manage_test_coins.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_manage_trading_bot.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_manage_weak_passwords.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_reset_activated_coins.dart';
import 'package:web_dex/views/settings/widgets/general_settings/settings_theme_switcher.dart';
import 'package:web_dex/views/settings/widgets/general_settings/show_swap_data.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) const SizedBox(height: 20),
        const SettingsThemeSwitcher(),
        const SizedBox(height: 25),
        const SettingsManageAnalytics(),
        const SizedBox(height: 25),
        const SettingsManageTestCoins(),
        const SizedBox(height: 25),
        const HiddenWithoutWallet(
          isHiddenForHw: true,
          child: SettingsManageWeakPasswords(),
        ),
        const SizedBox(height: 25),
        if (context.watch<TradingStatusBloc>().state is TradingEnabled)
          const HiddenWithoutWallet(
            isHiddenForHw: true,
            child: SettingsManageTradingBot(),
          ),
        const SizedBox(height: 25),
        const HiddenWithoutWallet(
          child: SettingsDownloadLogs(),
        ),
        const SizedBox(height: 25),
        const HiddenWithWallet(
          child: SettingsResetActivatedCoins(),
        ),
        const SizedBox(height: 25),
        const HiddenWithoutWallet(
          isHiddenForHw: true,
          child: ShowSwapData(),
        ),
        const HiddenWithoutWallet(
          isHiddenForHw: true,
          child: ImportSwaps(),
        ),
      ],
    );
  }
}
