import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/legacy_wallet_data.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/services/legacy_wallet_discovery_service.dart';
import 'package:web_dex/services/legacy_wallet_migration_service.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/wallets_manager/widgets/legacy_wallet_import.dart';

/// Enhanced widget that supports both automatic discovery and manual import
/// of legacy AtomicDEX desktop wallet data
class LegacyWalletImportEnhanced extends StatefulWidget {
  const LegacyWalletImportEnhanced({
    required this.onImport,
    required this.onCancel,
    super.key,
  });

  final void Function({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    LegacyWalletData? legacyData,
  }) onImport;

  final void Function() onCancel;

  @override
  State<LegacyWalletImportEnhanced> createState() =>
      _LegacyWalletImportEnhancedState();
}

enum LegacyImportMode {
  discovery, // Automatic discovery mode
  manual, // Manual file selection mode
}

class _LegacyWalletImportEnhancedState
    extends State<LegacyWalletImportEnhanced> {
  LegacyImportMode _mode = LegacyImportMode.discovery;
  final LegacyWalletDiscoveryService _discoveryService =
      LegacyWalletDiscoveryService();

  bool _isScanning = false;
  bool _hasScanned = false;
  LegacyDesktopInstallation? _discoveredInstallation;
  String? _discoveryError;

  @override
  void initState() {
    super.initState();
    // Start automatic discovery when widget is first shown
    _startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == LegacyImportMode.manual) {
      // Use the existing manual import widget
      return LegacyWalletImport(
        onImport: widget.onImport,
        onCancel: () {
          setState(() {
            _mode = LegacyImportMode.discovery;
          });
        },
      );
    }

    return _buildDiscoveryMode();
  }

  Widget _buildDiscoveryMode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legacy Wallet Import',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Searching for legacy AtomicDEX desktop wallet data on this device...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (_isScanning) ...[
          _buildScanningIndicator(),
        ] else if (_discoveredInstallation != null) ...[
          _buildDiscoveredInstallation(),
        ] else if (_hasScanned && _discoveredInstallation == null) ...[
          _buildNoInstallationFound(),
        ],
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildScanningIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Scanning for legacy wallet data...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveredInstallation() {
    if (_discoveredInstallation == null) return const SizedBox.shrink();

    final installation = _discoveredInstallation!;
    final summary = installation.getSummary();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Legacy Installation Found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Location', installation.dataPath),
            if (summary['walletFiles'] > 0)
              _buildSummaryRow('Wallet Files', '${summary['walletFiles']}'),
            if (summary['configFiles'] > 0)
              _buildSummaryRow('Config Files', '${summary['configFiles']}'),
            if (installation.walletFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Wallet Files:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              ...installation.walletFiles.map((file) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Text(
                      '${file.fileName} (${file.formattedSize})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            UiPrimaryButton(
              onPressed: _startAutoImport,
              text: 'Import Legacy Data',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInstallationFound() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No Legacy Installation Found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No legacy AtomicDEX desktop wallet data was found on this device. '
              'You can still import your wallet data manually if you have exported wallet files.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_discoveryError != null) ...[
              const SizedBox(height: 12),
              Text(
                'Error: $_discoveryError',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_discoveredInstallation == null) ...[
          Expanded(
            child: UiPrimaryButton(
              onPressed: _hasScanned ? _switchToManualMode : _startDiscovery,
              text: _hasScanned ? 'Import File Manually' : 'Scan Again',
            ),
          ),
        ] else ...[
          Expanded(
            child: UiPrimaryButton(
              onPressed: _switchToManualMode,
              text: 'Import File Manually',
            ),
          ),
        ],
        const SizedBox(width: 16),
        UiUnderlineTextButton(
          onPressed: widget.onCancel,
          text: LocaleKeys.cancel.tr(),
        ),
      ],
    );
  }

  void _startDiscovery() async {
    setState(() {
      _isScanning = true;
      _discoveryError = null;
      _discoveredInstallation = null;
    });

    try {
      final installation = await _discoveryService.discoverLegacyInstallation();

      setState(() {
        _isScanning = false;
        _hasScanned = true;
        _discoveredInstallation = installation;
      });

      if (installation != null) {
        log('Legacy installation discovered: ${installation.getSummary()}',
            path: 'LegacyWalletImportEnhanced._startDiscovery');
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _hasScanned = true;
        _discoveryError = e.toString();
      });

      log('Error during legacy discovery: $e',
          path: 'LegacyWalletImportEnhanced._startDiscovery', isError: true);
    }
  }

  void _startAutoImport() {
    if (_discoveredInstallation == null) return;

    // Show password dialog and then proceed with auto-import
    _showAutoImportDialog();
  }

  void _showAutoImportDialog() {
    showDialog(
      context: context,
      builder: (context) => _AutoImportDialog(
        installation: _discoveredInstallation!,
        discoveryService: _discoveryService,
        onImport: widget.onImport,
      ),
    );
  }

  void _switchToManualMode() {
    setState(() {
      _mode = LegacyImportMode.manual;
    });
  }
}

/// Dialog for handling automatic import with password entry
class _AutoImportDialog extends StatefulWidget {
  const _AutoImportDialog({
    required this.installation,
    required this.discoveryService,
    required this.onImport,
  });

  final LegacyDesktopInstallation installation;
  final LegacyWalletDiscoveryService discoveryService;
  final void Function({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    LegacyWalletData? legacyData,
  }) onImport;

  @override
  State<_AutoImportDialog> createState() => _AutoImportDialogState();
}

class _AutoImportDialogState extends State<_AutoImportDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isImporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill wallet name based on the most recent wallet file
    final walletFile = widget.installation.getMostRecentWalletFile();
    _nameController.text = walletFile.fileName.split('.').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Legacy Wallet'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiTextFormField(
              controller: _nameController,
              validator: _validateWalletName,
              hintText: 'Wallet Name',
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            UiTextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              hintText: 'Legacy Wallet Password',
              obscureText: true,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            UiTextFormField(
              controller: _newPasswordController,
              validator: _validateNewPassword,
              hintText: 'New Wallet Password',
              obscureText: true,
              autocorrect: false,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.cancel.tr()),
        ),
        UiPrimaryButton(
          onPressed: _isImporting ? null : _performAutoImport,
          text: _isImporting ? 'Importing...' : LocaleKeys.import.tr(),
        ),
      ],
    );
  }

  void _performAutoImport() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final result = await widget.discoveryService.autoMigrateLegacyData(
        installation: widget.installation,
        password: _passwordController.text,
        newWalletName: _nameController.text,
      );

      if (result.success && result.legacyData != null) {
        // TODO: Convert legacy data to wallet config
        // This would use the existing migration service to create the WalletConfig

        Navigator.of(context).pop();

        // Convert legacy data to wallet config using migration service
        try {
          final migrationService = LegacyWalletMigrationService();
          final walletConfig = await migrationService.convertToWalletConfig(
            legacyData: result.legacyData!,
            walletType: WalletType.hdwallet,
            newPassword: _newPasswordController.text,
          );

          widget.onImport(
            name: _nameController.text,
            password: _newPasswordController.text,
            walletConfig: walletConfig,
            legacyData: result.legacyData,
          );
        } catch (e) {
          setState(() {
            _error = 'Failed to convert legacy data: $e';
            _isImporting = false;
          });
        }
      } else {
        setState(() {
          _error = result.error ?? 'Import failed';
          _isImporting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Import failed: $e';
        _isImporting = false;
      });
    }
  }

  String? _validateWalletName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Wallet name is required';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
