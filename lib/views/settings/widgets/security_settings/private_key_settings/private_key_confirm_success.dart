import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/security_settings/security_settings_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_event.dart';
import 'package:web_dex/common/app_assets.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

/// Widget displaying successful completion of private key backup.
///
/// **Security Architecture**: This widget concludes the hybrid security approach:
/// - No sensitive data is stored or displayed here
/// - Confirms successful completion of the backup process
/// - Provides final security reminders to users
/// - Returns to main settings after user acknowledgment
///
/// **Security Note**: By this point, all private key data has been cleared
/// from memory in the parent widget, ensuring minimal exposure time.
/// This widget only handles the success notification and navigation.
class PrivateKeyConfirmSuccess extends StatelessWidget {
  /// Creates a new PrivateKeyConfirmSuccess widget.
  const PrivateKeyConfirmSuccess();

  @override
  Widget build(BuildContext context) {
    return isMobile ? const _MobileLayout() : const _DesktopLayout();
  }
}

/// Mobile-specific layout for the success screen.
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return DexScrollbar(
      scrollController: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 25),
                  DexSvgImage(path: Assets.seedSuccess),
                  SizedBox(height: 20),
                  _Title(),
                  SizedBox(height: 9),
                  _Body(),
                  SizedBox(height: 20),
                  _Button(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop-specific layout for the success screen.
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 25),
              DexSvgImage(path: Assets.seedSuccess),
              SizedBox(height: 20),
              _Title(),
              SizedBox(height: 9),
              _Body(),
              SizedBox(height: 20),
              _Button(),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget displaying the success title.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleKeys.privateKeyExportSuccessTitle.tr(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 16,
          ),
    );
  }
}

/// Widget displaying the success message and final security reminder.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 415),
      child: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKeys.privateKeyExportSuccessDescription.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to return to the main security settings screen.
///
/// **Security Note**: This button triggers a reset event which ensures
/// all sensitive data is cleared from the BLoC state and UI layer.
class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SecuritySettingsBloc>();

    /// Resets the security settings flow to return to the main screen.
    /// This ensures all states are cleared and no sensitive data persists.
    void gotoSecurityMain() => bloc.add(const ResetEvent());

    return UiPrimaryButton(
      key: const Key('private-key-confirm-got-it'),
      width: 198,
      height: isMobile ? 52 : 40,
      onPressed: gotoSecurityMain,
      text: LocaleKeys.seedPhraseGotIt.tr(),
    );
  }
}
