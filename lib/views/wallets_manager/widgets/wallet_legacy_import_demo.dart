import 'package:flutter/material.dart';
import 'package:web_dex/model/legacy_wallet_data.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/views/wallets_manager/widgets/legacy_wallet_import.dart';

/// Demo widget showing how to integrate LegacyWalletImport
/// This can be used as a reference for integration into the wallets manager
class WalletLegacyImportDemo extends StatefulWidget {
  const WalletLegacyImportDemo({super.key});

  @override
  State<WalletLegacyImportDemo> createState() => _WalletLegacyImportDemoState();
}

class _WalletLegacyImportDemoState extends State<WalletLegacyImportDemo> {
  bool _showImport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legacy Wallet Import Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showImport ? _buildImportWidget() : _buildStartButton(),
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showImport = true;
          });
        },
        child: const Text('Import Legacy AtomicDEX Desktop Wallet'),
      ),
    );
  }

  Widget _buildImportWidget() {
    return LegacyWalletImport(
      onImport: ({
        required String name,
        required String password,
        required WalletConfig walletConfig,
        LegacyWalletData? legacyData,
      }) {
        // Handle successful import
        _showSuccessDialog(name, legacyData);
      },
      onCancel: () {
        setState(() {
          _showImport = false;
        });
      },
    );
  }

  void _showSuccessDialog(String walletName, LegacyWalletData? legacyData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet "$walletName" has been imported successfully.'),
            const SizedBox(height: 16),
            if (legacyData != null) ...[
              const Text('Legacy data imported:'),
              const SizedBox(height: 8),
              Text('• Address book entries: ${legacyData.addressBook.length}'),
              Text('• Swap history entries: ${legacyData.swapHistory.length}'),
              Text('• Maker orders: ${legacyData.makerOrders.length}'),
              Text('• Makerbot configs: ${legacyData.makerbotConfigs.length}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showImport = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
