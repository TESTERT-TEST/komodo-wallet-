import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_event.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/bloc/analytics/analytics_bloc.dart';
import 'package:web_dex/analytics/events/security_events.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/seed_back_button.dart';

/// Widget for confirming that private keys have been securely saved.
///
/// **Security Architecture**: This widget is part of the hybrid security approach:
/// - No sensitive data (private keys) are stored in this widget
/// - Only manages user confirmation flow through [SecuritySettingsBloc]
/// - Provides clear security warnings and education
/// - Ensures user acknowledges responsibility for private key security
///
/// This confirmation step is crucial for private key backup as it:
/// - Educates users about private key security risks
/// - Requires explicit acknowledgment before proceeding
/// - Tracks completion for security analytics
/// - Ensures users understand the importance of secure storage
class PrivateKeyConfirmation extends StatefulWidget {
  /// Creates a new PrivateKeyConfirmation widget.
  const PrivateKeyConfirmation();

  @override
  State<PrivateKeyConfirmation> createState() => _PrivateKeyConfirmationState();
}

class _PrivateKeyConfirmationState extends State<PrivateKeyConfirmation> {
  /// Whether the user has confirmed they've saved their private keys securely.
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return DexScrollbar(
      isMobile: isMobile,
      scrollController: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!isMobile)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SeedBackButton(
                  () {
                    context.read<AnalyticsBloc>().add(
                          AnalyticsBackupSkippedEvent(
                            stageSkipped: 'private_key_confirm',
                            walletType: context
                                    .read<AuthBloc>()
                                    .state
                                    .currentUser
                                    ?.wallet
                                    .config
                                    .type
                                    .name ??
                                '',
                          ),
                        );
                    context
                        .read<SecuritySettingsBloc>()
                        .add(const ShowPrivateKeysEvent());
                  },
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: _Title(),
                  ),
                  const SizedBox(height: 24),
                  const _SecurityWarning(),
                  const SizedBox(height: 24),
                  _CheckboxConfirmation(
                    isConfirmed: _isConfirmed,
                    onChanged: (value) {
                      setState(() {
                        _isConfirmed = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _ConfirmButton(
                    onPressed: _isConfirmed ? _onConfirmPressed : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the confirmation button press.
  ///
  /// Triggers the completion event in the BLoC and logs analytics
  /// for security tracking purposes.
  void _onConfirmPressed() {
    final settingsBloc = context.read<SecuritySettingsBloc>();
    settingsBloc.add(const PrivateKeyConfirmedEvent());

    final walletType =
        context.read<AuthBloc>().state.currentUser?.wallet.config.type.name ??
            '';
    context.read<AnalyticsBloc>().add(
          AnalyticsBackupCompletedEvent(
            backupTime: 0,
            method: 'private_key_export',
            walletType: walletType,
          ),
        );
  }
}

/// Widget displaying the confirmation title and description.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LocaleKeys.confirmPrivateKeyBackup.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          LocaleKeys.confirmPrivateKeyBackupDescription.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

/// Widget displaying critical security warnings about private keys.
class _SecurityWarning extends StatelessWidget {
  const _SecurityWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.importantSecurityNotice.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.privateKeySecurityWarning.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

/// Checkbox widget for user confirmation of secure private key storage.
class _CheckboxConfirmation extends StatelessWidget {
  /// Creates a new _CheckboxConfirmation widget.
  ///
  /// [isConfirmed] Whether the user has confirmed secure storage.
  /// [onChanged] Callback when confirmation state changes.
  const _CheckboxConfirmation({
    required this.isConfirmed,
    required this.onChanged,
  });

  final bool isConfirmed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isConfirmed,
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            LocaleKeys.privateKeyBackupConfirmation.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Button to confirm completion of private key backup.
class _ConfirmButton extends StatelessWidget {
  /// Creates a new _ConfirmButton widget.
  ///
  /// [onPressed] Callback when button is pressed. Null if disabled.
  const _ConfirmButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final contentWidth = screenWidth - 80;
    final width = isMobile ? contentWidth : 207.0;
    final height = isMobile ? 52.0 : 40.0;

    return UiPrimaryButton(
      width: width,
      height: height,
      text: LocaleKeys.confirmBackupComplete.tr(),
      onPressed: onPressed,
    );
  }
}
