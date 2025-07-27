import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/security_settings/security_settings_bloc.dart';
import 'package:web_dex/bloc/security_settings/security_settings_event.dart';
import 'package:web_dex/bloc/security_settings/security_settings_state.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/bloc/analytics/analytics_bloc.dart';
import 'package:web_dex/analytics/events/security_events.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/utils/formatters.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/seed_back_button.dart';
import 'package:web_dex/views/wallet/coin_details/receive/qr_code_address.dart';

/// Widget for displaying private keys in a secure manner.
///
/// **Security Architecture**: This widget implements the UI layer of the hybrid
/// security approach for private key handling:
/// - Receives private key data directly from parent widget (not from BLoC state)
/// - Visibility state is managed by [SecuritySettingsBloc] for consistency
/// - Private key data never passes through shared state
/// - Provides secure viewing, copying, and QR code functionality
///
/// **Security Features**:
/// - Private keys are hidden by default
/// - Toggle visibility controlled by BLoC state
/// - Individual and bulk copy functionality
/// - QR code display for easy import
/// - Proper cleanup when widget is disposed
class PrivateKeyShow extends StatelessWidget {
  /// Creates a new PrivateKeyShow widget.
  ///
  /// [privateKeys] Map of asset IDs to their corresponding private keys.
  /// **Security Note**: This data should be handled with extreme care and
  /// cleared from memory as soon as possible.
  const PrivateKeyShow({
    required this.privateKeys,
  });

  /// Private keys organized by asset ID.
  ///
  /// **Security Note**: This data is intentionally passed directly to the UI
  /// rather than stored in BLoC state to minimize memory exposure and lifetime.
  final Map<AssetId, List<PrivateKey>> privateKeys;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return DexScrollbar(
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
                child: SeedBackButton(() {
                  context.read<AnalyticsBloc>().add(
                        AnalyticsBackupSkippedEvent(
                          stageSkipped: 'private_key_show',
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
                  context.read<SecuritySettingsBloc>().add(const ResetEvent());
                }),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TitleRow(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _ShowingSwitcher(),
                      _CopyAllPrivateKeysButton(privateKeys: privateKeys),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PrivateKeysList(privateKeys: privateKeys),
                  const SizedBox(height: 20),
                  const _PrivateKeysConfirmButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying the list of private keys by asset.
class _PrivateKeysList extends StatelessWidget {
  const _PrivateKeysList({
    required this.privateKeys,
  });

  final Map<AssetId, List<PrivateKey>> privateKeys;

  @override
  Widget build(BuildContext context) {
    if (privateKeys.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.privateKeys.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: privateKeys.length,
          itemBuilder: (context, index) {
            final assetId = privateKeys.keys.elementAt(index);
            final keys = privateKeys[assetId]!;

            return Card(
              color: Theme.of(context).colorScheme.onSurface,
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset header
                    Row(
                      children: [
                        Text(
                          assetId.id,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          '${keys.length} key${keys.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Private keys for this asset
                    ...keys.map((privateKey) => _PrivateKeyRow(
                          assetId: assetId,
                          privateKey: privateKey,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget for displaying a single private key with controls.
class _PrivateKeyRow extends StatelessWidget {
  const _PrivateKeyRow({
    required this.assetId,
    required this.privateKey,
  });

  final AssetId assetId;
  final PrivateKey privateKey;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SecuritySettingsBloc, SecuritySettingsState, bool>(
      selector: (state) => state.showPrivateKeys,
      builder: (context, showPrivateKeys) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (privateKey.hdInfo?.derivationPath != null) ...[
                Text(
                  'Path: ${privateKey.hdInfo!.derivationPath}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      showPrivateKeys
                          ? truncateMiddleSymbols(privateKey.privateKey, 8, 8)
                          : '••••••••••••••••••••••••••••••••',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.copy),
                    onPressed: showPrivateKeys
                        ? () {
                            copyToClipBoard(context, privateKey.privateKey);
                            context
                                .read<SecuritySettingsBloc>()
                                .add(const ShowPrivateKeysCopiedEvent());
                          }
                        : null,
                  ),
                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.qr_code),
                    onPressed: showPrivateKeys
                        ? () {
                            _showQrDialog(context, assetId, privateKey);
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a QR code dialog for the private key.
  ///
  /// **Security Note**: Only shown when private keys are visible and
  /// user explicitly requests it.
  void _showQrDialog(
      BuildContext context, AssetId assetId, PrivateKey privateKey) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        assetId.id,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  if (privateKey.hdInfo?.derivationPath != null) ...[
                    Text(
                      'Path: ${privateKey.hdInfo!.derivationPath}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                  QRCodeAddress(currentAddress: privateKey.privateKey),
                  const SizedBox(height: 16),
                  SelectableText(
                    privateKey.privateKey,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget displaying the title and security warning for private key export.
class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.privateKeyExportTitle.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          LocaleKeys.privateKeyExportDescription.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.custom.warningColor.withValues(alpha: 0.1),
            border: Border.all(color: theme.custom.warningColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: theme.custom.warningColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LocaleKeys.copyWarning.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.custom.warningColor,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Button for copying all private keys to clipboard.
class _CopyAllPrivateKeysButton extends StatelessWidget {
  const _CopyAllPrivateKeysButton({required this.privateKeys});
  final Map<AssetId, List<PrivateKey>> privateKeys;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SecuritySettingsBloc, SecuritySettingsState, bool>(
      selector: (state) => state.showPrivateKeys,
      builder: (context, showPrivateKeys) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: showPrivateKeys
                ? () {
                    final allKeys = <String>[];
                    privateKeys.forEach((assetId, keys) {
                      for (final key in keys) {
                        final pathInfo = key.hdInfo?.derivationPath != null
                            ? ' (${key.hdInfo!.derivationPath})'
                            : '';
                        allKeys
                            .add('${assetId.id}$pathInfo: ${key.privateKey}');
                      }
                    });
                    copyToClipBoard(context, allKeys.join('\n'));
                    context
                        .read<SecuritySettingsBloc>()
                        .add(const ShowPrivateKeysCopiedEvent());
                  }
                : null,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: [
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: showPrivateKeys
                        ? theme.currentGlobal.textTheme.bodySmall?.color
                        : theme.currentGlobal.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    LocaleKeys.copyAllKeys.tr(),
                    style: theme.currentGlobal.textTheme.bodySmall?.copyWith(
                      color: showPrivateKeys
                          ? null
                          : theme.currentGlobal.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Toggle switch for showing/hiding private keys.
class _ShowingSwitcher extends StatelessWidget {
  const _ShowingSwitcher();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SecuritySettingsBloc>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UiSwitcher(
          value: bloc.state.showPrivateKeys,
          onChanged: (isChecked) =>
              bloc.add(ShowPrivateKeysWordsEvent(isChecked)),
          width: 38,
          height: 21,
        ),
        const SizedBox(width: 6),
        SelectableText(
          LocaleKeys.showPrivateKeys.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

/// Button to confirm that private keys have been saved.
class _PrivateKeysConfirmButton extends StatelessWidget {
  const _PrivateKeysConfirmButton();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SecuritySettingsBloc>();

    void onPressed() => bloc.add(const PrivateKeyConfirmEvent());
    final text = LocaleKeys.iHaveSavedMyPrivateKeys.tr();

    final contentWidth = screenWidth - 80;
    final width = isMobile ? contentWidth : 207.0;
    final height = isMobile ? 52.0 : 40.0;

    return BlocSelector<SecuritySettingsBloc, SecuritySettingsState, bool>(
      selector: (state) => state.arePrivateKeysSaved,
      builder: (context, isSaved) {
        return UiPrimaryButton(
          width: width,
          height: height,
          text: text,
          onPressed: isSaved ? onPressed : null,
        );
      },
    );
  }
}
