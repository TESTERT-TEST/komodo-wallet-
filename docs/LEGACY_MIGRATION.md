# Legacy AtomicDEX Desktop Wallet Migration

This implementation provides migration support for importing legacy AtomicDEX desktop wallet data into the new cross-platform Komodo wallet app, addressing GitHub issue #2717.

## Overview

The legacy migration system enables users to import their encrypted seed files, maker orders, makerbot configs, address books, and swap histories from the legacy AtomicDEX desktop application into the new app.

### Migration Methods

The system supports two migration approaches:

1. **Manual File Import**: Users manually select legacy wallet files for import
2. **Automatic Discovery**: Automatic detection and import of legacy wallet data when the legacy desktop app was used on the same device

## Architecture

### Core Components

1. **LegacyDesktopDecryption** (`lib/services/legacy_desktop_decryption.dart`)

   - FFI-based decryption using libsodium
   - Handles XChaCha20-Poly1305 encryption used by legacy desktop app
   - Platform-specific library loading for Windows, macOS, and Linux

2. **LegacyWalletData** (`lib/model/legacy_wallet_data.dart`)

   - Data models representing legacy wallet structures
   - Supports address books, swap history, maker orders, and makerbot configs
   - JSON serialization for data transformation

3. **LegacyWalletMigrationService** (`lib/services/legacy_wallet_migration_service.dart`)

   - Orchestrates the migration process
   - Format detection and validation
   - Conversion from legacy to new wallet format

4. **LegacyWalletDiscoveryService** (`lib/services/legacy_wallet_discovery_service.dart`)

   - Automatic discovery of legacy wallet installations
   - Platform-specific path detection (Windows: %APPDATA%, macOS: ~/Library/Application Support, Linux: ~/.atomicdex-desktop)
   - Filesystem scanning and validation of legacy wallet files

5. **EncryptionTool Extensions** (`lib/services/encryption_tool.dart`)

   - Extended to support legacy format detection
   - Integrates with LegacyDesktopDecryption for seamless operation

6. **LegacyWalletImport Widget** (`lib/views/wallets_manager/widgets/legacy_wallet_import.dart`)

   - Manual file import UI for legacy wallets
   - Three-step process: file selection, password entry, data review
   - Comprehensive error handling and validation

7. **LegacyWalletImportEnhanced Widget** (`lib/views/wallets_manager/widgets/legacy_wallet_import_enhanced.dart`)
   - Enhanced UI supporting both manual and automatic import modes
   - Automatic discovery with fallback to manual file selection
   - Seamless user experience for same-device migration

## Encryption Differences

### Legacy Desktop (libsodium)

- **Algorithm**: XChaCha20-Poly1305 with crypto_secretstream
- **Key Derivation**: PBKDF2 with 10,000 iterations
- **Salt**: Zeroed 32-byte salt
- **Format**: Chunked encryption with headers

### Current App (Dart crypto)

- **Algorithm**: AES-CBC with HMAC
- **Key Derivation**: PBKDF2 with random salt
- **Format**: Single-block encryption with IV

## Usage

### For Users

#### Migrating from Legacy AtomicDEX Desktop

If you previously used the AtomicDEX desktop application and want to import your wallet data into the new Komodo Wallet:

##### Method 1: Automatic Discovery (Recommended)

This method works when you're using the new Komodo Wallet on the same device where you had AtomicDEX desktop installed:

1. **Open Komodo Wallet** and navigate to the wallet management section
2. **Select "Import Legacy Wallet"** or "Migrate from AtomicDEX Desktop"
3. **Choose "Automatic Discovery"** if available
4. The app will automatically scan for legacy wallet data in standard locations:
   - Windows: `%APPDATA%\atomicdex-desktop`
   - macOS: `~/Library/Application Support/atomicdex-desktop`
   - Linux: `~/.atomicdex-desktop`
5. **Select the wallet** you want to import from the discovered list
6. **Enter your legacy wallet password**
7. **Choose a new wallet name** for the imported wallet
8. **Set a new password** for the wallet in Komodo Wallet
9. **Confirm the import** - your wallet data will be migrated automatically

##### Method 2: Manual File Import

Use this method if automatic discovery doesn't work or if you have wallet files from a different device:

1. **Locate your legacy wallet files** from your AtomicDEX desktop installation
   - Look for `.dat` files or encrypted wallet files
   - These are typically in the data directories mentioned above
2. **Open Komodo Wallet** and navigate to wallet management
3. **Select "Import Legacy Wallet"** and choose "Manual Import"
4. **Click "Select File"** and browse to your legacy wallet file
5. **Enter the password** you used for the legacy wallet
6. **Review the wallet data** that will be imported (coins, addresses, etc.)
7. **Choose a new wallet name**
8. **Set a new password** for the wallet in Komodo Wallet
9. **Complete the import** - your data will be converted and imported

#### What Gets Migrated

When you import a legacy wallet, the following data is transferred:

- ✅ **Wallet seed phrase** (encrypted with your new password)
- ✅ **Address book entries** (contact names and addresses)
- ✅ **Swap history** (previous atomic swap transactions)
- ✅ **Maker orders** (trading orders you had set up)
- ✅ **Makerbot configurations** (automated trading settings)
- ✅ **General settings** (preferences and configurations)

#### Troubleshooting for Users

##### "Automatic discovery found no wallets"

- Make sure you're on the same device where AtomicDEX desktop was installed
- Check if the legacy app data folders exist
- Try the manual import method instead

##### "Password incorrect" error

- Double-check you're using the correct password from your legacy wallet
- Make sure caps lock is off
- Try typing the password in a text editor first to verify it

##### "File not recognized" error

- Ensure you're selecting the correct wallet file (usually has `.dat` extension)
- Make sure the file isn't corrupted
- Try selecting a different wallet file if you have multiple

##### Permission denied errors (macOS)

- Go to System Preferences > Security & Privacy > Privacy
- Select "Full Disk Access" and add Komodo Wallet to the list
- Restart the app and try again

### For Developers

#### Enhanced Import (Recommended)

The enhanced import widget automatically detects legacy wallet installations and provides a seamless migration experience:

```dart
import 'package:web_dex/views/wallets_manager/widgets/legacy_wallet_import_enhanced.dart';

LegacyWalletImportEnhanced(
  onImport: ({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    LegacyWalletData? legacyData,
  }) {
    // Handle successful import
    walletRepository.addWallet(walletConfig);
    if (legacyData != null) {
      // Import legacy data (address book, swap history, etc.)
      addressBookService.importLegacyEntries(legacyData.addressBook);
      swapHistoryService.importLegacyEntries(legacyData.swapHistory);
    }
  },
  onCancel: () {
    // Handle cancellation
  },
)
```

### Manual File Import

For users who prefer manual file selection or when automatic discovery is not available:

```dart
import 'package:web_dex/views/wallets_manager/widgets/legacy_wallet_import.dart';

LegacyWalletImport(
  onImport: ({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    LegacyWalletData? legacyData,
  }) {
    // Handle successful import
    walletRepository.addWallet(walletConfig);
    if (legacyData != null) {
      // Import legacy data (address book, swap history, etc.)
      addressBookService.importLegacyEntries(legacyData.addressBook);
      swapHistoryService.importLegacyEntries(legacyData.swapHistory);
    }
  },
  onCancel: () {
    // Handle cancellation
  },
)
```

### Automatic Discovery Service

For programmatic access to the discovery functionality:

```dart
import 'package:web_dex/services/legacy_wallet_discovery_service.dart';

final discoveryService = LegacyWalletDiscoveryService();

// Discover legacy installations
final installations = await discoveryService.discoverLegacyInstallations();

for (final installation in installations) {
  print('Found legacy wallet: ${installation.name}');
  print('Path: ${installation.path}');
  print('Wallets: ${installation.walletFiles.length}');
}

// Auto-migrate discovered wallet
final result = await discoveryService.autoMigrateLegacyData(
  installationPath: installations.first.path,
  walletName: 'MyWallet',
  password: 'user_password',
);

if (result.success) {
  final walletConfig = await migrationService.convertToWalletConfig(
    legacyData: result.legacyData!,
    walletType: WalletType.hdwallet,
    newPassword: 'new_password',
  );
}
```

### Basic Integration

```dart
import 'package:web_dex/views/wallets_manager/widgets/legacy_wallet_import.dart';

LegacyWalletImport(
  onImport: ({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    LegacyWalletData? legacyData,
  }) {
    // Handle successful import
    walletRepository.addWallet(walletConfig);
    if (legacyData != null) {
      // Import legacy data (address book, swap history, etc.)
      addressBookService.importLegacyEntries(legacyData.addressBook);
      swapHistoryService.importLegacyEntries(legacyData.swapHistory);
    }
  },
  onCancel: () {
    // Handle cancellation
  },
)
```

### Direct Service Usage

```dart
final migrationService = LegacyWalletMigrationService();

// Check if file is legacy format
if (migrationService.isLegacyDesktopFormat(fileData)) {
  // Migrate the wallet
  final legacyData = await migrationService.migrateLegacyWallet(
    fileData: fileData,
    password: password,
    newWalletName: walletName,
  );

  // Convert to new format
  final walletConfig = await migrationService.convertToWalletConfig(
    legacyData: legacyData,
    walletType: WalletType.hdwallet,
    newPassword: newPassword,
  );
}
```

## Dependencies

### Native Libraries

- **libsodium**: Required for legacy decryption
  - Windows: `libsodium.dll`
  - macOS: `libsodium.dylib`
  - Linux: `libsodium.so`

### Dart Packages

- `dart:ffi` - For native library bindings
- `crypto` - For current encryption methods
- `convert` - For base64 encoding/decoding

## Security Considerations

1. **Memory Management**: Sensitive data is cleared after use
2. **Password Validation**: Strong password requirements enforced
3. **Format Validation**: Strict validation of legacy file formats
4. **Error Handling**: No sensitive information leaked in error messages

## Platform Support

- ✅ **Windows**: Full support with libsodium.dll
  - Legacy data location: `%APPDATA%\atomicdex-desktop`
- ✅ **macOS**: Full support with libsodium.dylib
  - Legacy data location: `~/Library/Application Support/atomicdex-desktop`
- ✅ **Linux**: Full support with libsodium.so
  - Legacy data location: `~/.atomicdex-desktop`
- ⚠️ **Web**: Limited support (no native library access, no automatic discovery)
- ⚠️ **Mobile**: Limited support (library availability dependent, no automatic discovery)

## File Format Support

### Supported Legacy Files

- AtomicDEX desktop wallet files (`.dat` extension typically)
- Encrypted seed files using XChaCha20-Poly1305
- JSON-based configuration files

### Data Types Migrated

- **Encrypted Seeds**: Main wallet seed phrases
- **Address Book**: Contact addresses and names
- **Swap History**: Previous atomic swap transactions
- **Maker Orders**: Active and historical maker orders
- **Makerbot Configs**: Automated trading configurations

## Error Handling

The migration system provides comprehensive error handling for:

- **File Access Errors**: Invalid or corrupted files
- **Decryption Errors**: Wrong passwords or encryption failures
- **Format Errors**: Unsupported file formats
- **Library Errors**: Missing or incompatible native libraries
- **Validation Errors**: Invalid wallet data structures

## Testing

### Unit Tests

```bash
# Test legacy migration service
flutter test test_units/services/legacy_wallet_migration_service_test.dart

# Test automatic discovery service
flutter test test_units/services/legacy_wallet_discovery_service_test.dart
```

### Integration Tests

```bash
# Test complete migration flow
flutter test test_integration/legacy_migration_test.dart

# Test automatic discovery and migration
flutter test test_integration/legacy_discovery_test.dart
```

## Troubleshooting

### Common Issues

1. **Library Not Found**

   - Ensure libsodium is installed on the system
   - Check library path configuration

2. **Decryption Failures**

   - Verify password correctness
   - Check file integrity

3. **Format Detection Issues**

   - Ensure file is from AtomicDEX desktop application
   - Verify file hasn't been corrupted during transfer

4. **Automatic Discovery Not Working**

   - Check if legacy AtomicDEX desktop was installed on the same device
   - Verify default installation paths exist
   - On Windows: `%APPDATA%\atomicdx-desktop`
   - On macOS: `~/Library/Application Support/atomicdx-desktop`
   - On Linux: `~/.atomicdx-desktop`

5. **Permission Issues**

   - Ensure the app has read permissions for legacy data directories
   - On macOS, may require granting Full Disk Access in Security & Privacy settings

### Debug Mode

Enable debug logging for detailed migration process information:

```dart
LegacyWalletMigrationService(enableDebugLogging: true)
```

## Future Enhancements

1. **Enhanced Format Support**: Support for additional legacy wallet formats
2. **Batch Import**: Import multiple wallets simultaneously
3. **Progress Indicators**: Detailed progress tracking for large imports
4. **Data Validation**: Enhanced validation of imported data
5. **Recovery Options**: Partial import support for corrupted files
6. **Cross-Platform Discovery**: Enhanced discovery for portable installations
7. **Cloud Integration**: Support for discovering legacy data in cloud storage

## Contributing

When contributing to the legacy migration system:

1. Maintain backward compatibility with existing legacy formats
2. Add comprehensive tests for new features
3. Update documentation for any API changes
4. Consider security implications of new functionality

## License

This implementation is part of the Komodo Wallet project and follows the same licensing terms.
