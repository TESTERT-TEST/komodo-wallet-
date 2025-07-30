import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:web_dex/bloc/coins_bloc/coins_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_event.dart';
import 'package:web_dex/bloc/security_settings/security_settings_state.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/show_priv_key/show_priv_key_request.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/common/page_header/page_header.dart';
import 'package:web_dex/views/common/pages/page_layout.dart';
import 'package:web_dex/views/common/wallet_password_dialog/wallet_password_dialog.dart';
import 'package:web_dex/views/settings/widgets/common/settings_content_wrapper.dart';
import 'package:web_dex/views/settings/widgets/security_settings/password_update_page.dart';
import 'package:web_dex/views/settings/widgets/security_settings/security_settings_main_page.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/seed_confirm_success.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/seed_confirmation/seed_confirmation.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/seed_show.dart';
import 'package:web_dex/views/settings/widgets/security_settings/private_key_settings/private_key_show.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';

/// Security settings page that manages both seed phrase and private key backup flows.
///
/// **Security Architecture**: This page implements a hybrid security approach:
/// - **Authentication and flow control** are managed by [SecuritySettingsBloc]
/// - **Sensitive data (private keys)** are handled directly in this UI layer
/// - Private keys are stored in local variables with minimal lifetime
/// - Automatic cleanup ensures sensitive data doesn't persist in memory
///
/// This approach balances clean architecture with maximum security for cryptocurrency
/// private key handling, following industry best practices for sensitive data management.
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({required this.onBackPressed, super.key});

  final VoidCallback onBackPressed;

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  String _seed = '';
  final Map<Coin, String> _privKeys = {};

  /// Private keys fetched from SDK - stored locally for minimal memory exposure.
  ///
  /// **Security Note**: These are intentionally stored in the UI layer rather than
  /// in BLoC state to minimize their memory lifetime and scope. They are:
  /// - Fetched only after authentication succeeds
  /// - Cleared immediately when no longer needed
  /// - Never passed through shared state or persisted
  /// - Automatically cleaned up when widget disposes
  Map<AssetId, List<PrivateKey>>? _sdkPrivateKeys;

  @override
  void dispose() {
    // Ensure sensitive data is cleared when widget is disposed
    _clearAllSensitiveData();
    super.dispose();
  }

  /// Clears all sensitive data from memory.
  ///
  /// This method ensures that private keys and seed phrases don't persist
  /// in memory longer than necessary. Called when:
  /// - Widget is disposed
  /// - Navigating away from private key flows
  /// - Any error occurs during private key operations
  void _clearAllSensitiveData() {
    _seed = '';
    _privKeys.clear();
    _sdkPrivateKeys?.clear();
    _sdkPrivateKeys = null;
  }

  /// Clears only private key data while preserving seed data.
  ///
  /// Used when transitioning between different security flows.
  void _clearPrivateKeyData() {
    _sdkPrivateKeys?.clear();
    _sdkPrivateKeys = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SecuritySettingsBloc>(
      create: (context) => SecuritySettingsBloc(
        SecuritySettingsState.initialState(),
        kdfSdk: RepositoryProvider.of<KomodoDefiSdk>(context),
      ),
      child: MultiBlocListener(
        listeners: [
          // Listen for step changes to manage sensitive data cleanup
          BlocListener<SecuritySettingsBloc, SecuritySettingsState>(
            listenWhen: (previous, current) => previous.step != current.step,
            listener: (context, state) {
              _handleStepChange(state.step);
            },
          ),
        ],
        child: BlocBuilder<SecuritySettingsBloc, SecuritySettingsState>(
          builder: (BuildContext context, SecuritySettingsState state) {
            final Widget content = _buildContent(state.step);
            if (isMobile) {
              return _SecuritySettingsPageMobile(
                content: content,
                onBackButtonPressed: () =>
                    _handleBackButton(context, state.step),
              );
            }
            return content;
          },
        ),
      ),
    );
  }

  /// Handles back button navigation based on current step.
  void _handleBackButton(BuildContext context, SecuritySettingsStep step) {
    switch (step) {
      case SecuritySettingsStep.securityMain:
        widget.onBackPressed();
        break;
      case SecuritySettingsStep.seedConfirm:
        context.read<SecuritySettingsBloc>().add(const ShowSeedEvent());
        break;
      case SecuritySettingsStep.seedShow:
      case SecuritySettingsStep.seedSuccess:
      case SecuritySettingsStep.privateKeyShow:
      case SecuritySettingsStep.passwordUpdate:
        context.read<SecuritySettingsBloc>().add(const ResetEvent());
        break;
    }
  }

  /// Handles step changes to manage sensitive data lifecycle.
  ///
  /// Clears sensitive data when navigating away from private key flows
  /// to minimize memory exposure.
  void _handleStepChange(SecuritySettingsStep step) {
    switch (step) {
      case SecuritySettingsStep.securityMain:
      case SecuritySettingsStep.seedShow:
      case SecuritySettingsStep.seedConfirm:
      case SecuritySettingsStep.seedSuccess:
      case SecuritySettingsStep.passwordUpdate:
        // Clear private key data when not in private key flow
        _clearPrivateKeyData();
        break;
      case SecuritySettingsStep.privateKeyShow:
        // Private key data should persist during private key flow
        break;
    }
  }

  /// Builds the appropriate content widget based on the current step.
  Widget _buildContent(SecuritySettingsStep step) {
    switch (step) {
      case SecuritySettingsStep.securityMain:
        _clearAllSensitiveData(); // Clear data when returning to main
        return SecuritySettingsMainPage(
          onViewSeedPressed: onViewSeedPressed,
          onViewPrivateKeysPressed: onViewPrivateKeysPressed,
        );

      case SecuritySettingsStep.seedShow:
        return SeedShow(seedPhrase: _seed, privKeys: _privKeys);

      case SecuritySettingsStep.seedConfirm:
        return SeedConfirmation(seedPhrase: _seed);

      case SecuritySettingsStep.seedSuccess:
        _clearAllSensitiveData(); // Clear data after successful seed backup
        return const SeedConfirmSuccess();

      case SecuritySettingsStep.privateKeyShow:
        return PrivateKeyShow(privateKeys: _sdkPrivateKeys ?? {});

      case SecuritySettingsStep.passwordUpdate:
        _clearAllSensitiveData(); // Clear data when changing password
        return const PasswordUpdatePage();
    }
  }

  /// Handles seed phrase export - uses existing legacy approach.
  ///
  /// This maintains backward compatibility with the existing seed phrase
  /// backup flow while the private key flow uses the new hybrid approach.
  Future<void> onViewSeedPressed(BuildContext context) async {
    final SecuritySettingsBloc securitySettingsBloc = context
        .read<SecuritySettingsBloc>();

    final String? pass = await walletPasswordDialog(context);
    if (pass == null) return;

    // ignore: use_build_context_synchronously
    final coinsBloc = context.read<CoinsBloc>();
    // ignore: use_build_context_synchronously
    final mm2Api = RepositoryProvider.of<Mm2Api>(context);
    // ignore: use_build_context_synchronously
    final kdfSdk = RepositoryProvider.of<KomodoDefiSdk>(context);

    final mnemonic = await kdfSdk.auth.getMnemonicPlainText(pass);
    _seed = mnemonic.plaintextMnemonic ?? '';

    _privKeys.clear();
    final parentCoins = coinsBloc.state.walletCoins.values.where(
      (coin) => !coin.id.isChildAsset,
    );
    for (final coin in parentCoins) {
      final result = await mm2Api.showPrivKey(
        ShowPrivKeyRequest(coin: coin.abbr),
      );
      if (result != null) {
        _privKeys[coin] = result.privKey;
      }
    }

    securitySettingsBloc.add(const ShowSeedEvent());
  }

  /// Initiates private key export flow using hybrid security approach.
  ///
  /// **Security Flow**:
  /// 1. Shows password dialog with loading state
  /// 2. Dialog validates authentication and shows loading indicator
  /// 3. Fetches private keys while dialog remains open
  /// 4. Dialog closes only after private keys are ready or error occurs
  /// 5. Private keys are stored locally in UI layer only
  ///
  /// This approach provides better UX by showing loading state during the entire operation.
  Future<void> onViewPrivateKeysPressed(BuildContext context) async {
    final bool success = await walletPasswordDialogWithLoading(
      context,
      onPasswordValidated: (String password) async {
        try {
          // Fetch private keys directly into local UI state
          // This keeps sensitive data in minimal scope
          _sdkPrivateKeys = await context.sdk.security.getPrivateKeys();

          return true; // Success
        } catch (e) {
          // Clear sensitive data on any error
          _clearPrivateKeyData();

          // Log error for debugging
          debugPrint('Failed to retrieve private keys: ${e.toString()}');

          return false; // Failure
        }
      },
      loadingTitle: LocaleKeys.fetchingPrivateKeysTitle.tr(),
      loadingMessage: LocaleKeys.fetchingPrivateKeysMessage.tr(),
      operationFailedMessage: LocaleKeys.privateKeyRetrievalFailed.tr(),
      passwordFieldKey: 'confirmation-showing-private-keys',
    );

    if (!mounted) return;

    if (success) {
      // Private keys are ready, show the private keys screen
      // ignore: use_build_context_synchronously
      context.read<SecuritySettingsBloc>().add(const ShowPrivateKeysEvent());
    } else {
      // Show error to user
      // ignore: use_build_context_synchronously
      _showPrivateKeyError(context, LocaleKeys.privateKeyRetrievalFailed.tr());
    }
  }

  /// Shows private key retrieval error to the user.
  void _showPrivateKeyError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// Mobile wrapper for security settings page.
class _SecuritySettingsPageMobile extends StatelessWidget {
  const _SecuritySettingsPageMobile({
    required this.content,
    required this.onBackButtonPressed,
  });

  final Widget content;
  final VoidCallback onBackButtonPressed;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: PageHeader(
        title: LocaleKeys.securitySettings.tr(),
        onBackButtonPressed: onBackButtonPressed,
      ),
      content: Flexible(child: SettingsContentWrapper(child: content)),
    );
  }
}
