# Legacy AtomicDEX Desktop Wallet Migration

This implementation provides migration support for importing legacy AtomicDEX desktop wallet data into the new cross-platform Komodo wallet app, addressing GitHub issue #2717.

## Overview

The legacy migration system enables users to import their encrypted seed files, maker orders, makerbot configs, address books, and swap histories from the legacy AtomicDEX desktop application into the new app.

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

4. **EncryptionTool Extensions** (`lib/services/encryption_tool.dart`)

   - Extended to support legacy format detection
   - Integrates with LegacyDesktopDecryption for seamless operation

5. **LegacyWalletImport Widget** (`lib/views/wallets_manager/widgets/legacy_wallet_import.dart`)
   - Complete UI for importing legacy wallets
   - Three-step process: file selection, password entry, data review
   - Comprehensive error handling and validation

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
- ✅ **macOS**: Full support with libsodium.dylib
- ✅ **Linux**: Full support with libsodium.so
- ⚠️ **Web**: Limited support (no native library access)
- ⚠️ **Mobile**: Limited support (library availability dependent)

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
flutter test test_units/services/legacy_wallet_migration_service_test.dart
```

### Integration Tests

```bash
flutter test test_integration/legacy_migration_test.dart
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

## Contributing

When contributing to the legacy migration system:

1. Maintain backward compatibility with existing legacy formats
2. Add comprehensive tests for new features
3. Update documentation for any API changes
4. Consider security implications of new functionality

## License

This implementation is part of the Komodo Wallet project and follows the same licensing terms.
