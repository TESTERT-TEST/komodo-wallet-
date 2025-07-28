import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/system_health/system_health_bloc.dart';
import 'package:web_dex/bloc/trading_status/trading_status_bloc.dart';
import 'package:web_dex/blocs/maker_form_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

class MakerFormTradeButton extends StatelessWidget {
  const MakerFormTradeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemHealthBloc, SystemHealthState>(
        builder: (context, systemHealthState) {
      // Determine if system clock is valid
      final bool isSystemClockValid =
          systemHealthState is SystemHealthLoadSuccess &&
              systemHealthState.isValid;

      final tradingState = context.watch<TradingStatusBloc>().state;
      final isTradingEnabled = tradingState.isEnabled;

      final makerFormBloc = RepositoryProvider.of<MakerFormBloc>(context);
      final authBloc = context.watch<AuthBloc>();

      return StreamBuilder<bool>(
          initialData: makerFormBloc.inProgress,
          stream: makerFormBloc.outInProgress,
          builder: (context, snapshot) {
            final bool inProgress = snapshot.data ?? false;
            final bool disabled = inProgress || !isSystemClockValid;

            return Opacity(
              opacity: disabled ? 0.8 : 1,
              child: UiPrimaryButton(
                key: const Key('make-order-button'),
                text: isTradingEnabled
                    ? LocaleKeys.makeOrder.tr()
                    : LocaleKeys.tradingDisabled.tr(),
                prefix: inProgress
                    ? Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: UiSpinner(
                          width: 10,
                          height: 10,
                          strokeWidth: 1,
                          color: theme.custom.defaultGradientButtonTextColor,
                        ),
                      )
                    : null,
                onPressed: disabled || !isTradingEnabled
                    ? null
                    : () async {
                        while (!authBloc.state.isSignedIn) {
                          await Future<dynamic>.delayed(
                              const Duration(milliseconds: 300));
                        }
                        final bool isValid = await makerFormBloc.validate();
                        if (!isValid) return;

                        makerFormBloc.showConfirmation = true;
                      },
                height: 40,
              ),
            );
          });
    });
  }
}
