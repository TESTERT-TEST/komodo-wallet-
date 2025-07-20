import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'mocks/mock_failing_binance_provider.dart';

void testFailingBinanceRepository() {
  late BinanceRepository binanceRepository;
  late AssetId kmdAssetId;

  setUp(() {
    binanceRepository = BinanceRepository(
      binanceProvider: const MockFailingBinanceProvider(),
    );

    // Create KMD AssetId for tests
    kmdAssetId = AssetId(
      id: 'KMD',
      name: 'Komodo',
      symbol: AssetSymbol(assetConfigId: 'KMD'),
      chainId: AssetChainId(chainId: 0),
      derivationPath: '',
      subClass: CoinSubClass.utxo,
    );
  });

  group('Failing BinanceRepository Requests', () {
    test('Coin list is empty if all requests to binance fail', () async {
      final response = await binanceRepository.getCoinList();
      expect(response, isEmpty);
    });

    test('OHLC request rethrows [UnsupportedError] if all requests fail',
        () async {
      expect(
        () async {
          final response = await binanceRepository.getCoinOhlc(
            const CexCoinPair.usdtPrice('KMD'),
            GraphInterval.oneDay,
          );
          return response;
        },
        throwsUnsupportedError,
      );
    });

    test('Coin fiat price throws [UnsupportedError] if all requests fail',
        () async {
      expect(
        () async {
          final response = await binanceRepository.getCoinFiatPrice(kmdAssetId);
          return response;
        },
        throwsUnsupportedError,
      );
    });

    test('Coin fiat prices throws [UnsupportedError] if all requests fail',
        () async {
      expect(
        () async {
          final response = await binanceRepository
              .getCoinFiatPrices(kmdAssetId, [DateTime.now()]);
          return response;
        },
        throwsUnsupportedError,
      );
    });
  });
}
