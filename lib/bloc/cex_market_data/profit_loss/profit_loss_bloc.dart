import 'dart:async';
import 'dart:math' show Point;

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:logging/logging.dart';
import 'package:web_dex/bloc/cex_market_data/charts.dart';
import 'package:web_dex/bloc/cex_market_data/profit_loss/profit_loss_repository.dart';
import 'package:web_dex/bloc/cex_market_data/sdk_auth_activation_extension.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/text_error.dart';

part 'profit_loss_event.dart';
part 'profit_loss_state.dart';

class ProfitLossBloc extends Bloc<ProfitLossEvent, ProfitLossState> {
  ProfitLossBloc(this._profitLossRepository, this._sdk)
      : super(const ProfitLossInitial()) {
    // Use the restartable transformer for load events to avoid overlapping
    // events if the user rapidly changes the period (i.e. faster than the
    // previous event can complete).
    on<ProfitLossPortfolioChartLoadRequested>(
      _onLoadPortfolioProfitLoss,
      transformer: restartable(),
    );
    on<ProfitLossPortfolioPeriodChanged>(_onPortfolioPeriodChanged);
    on<ProfitLossPortfolioChartClearRequested>(_onClearPortfolioProfitLoss);
  }

  final ProfitLossRepository _profitLossRepository;
  final KomodoDefiSdk _sdk;

  final _log = Logger('ProfitLossBloc');

  void _onClearPortfolioProfitLoss(
    ProfitLossPortfolioChartClearRequested event,
    Emitter<ProfitLossState> emit,
  ) {
    emit(const ProfitLossInitial());
  }

  Future<void> _onLoadPortfolioProfitLoss(
    ProfitLossPortfolioChartLoadRequested event,
    Emitter<ProfitLossState> emit,
  ) async {
    try {
      final supportedCoins =
          await _removeUnsupportedCons(event.coins, event.fiatCoinId);
      // Charts for individual coins (coin details) are parsed here as well,
      // and should be hidden if not supported.
      if (supportedCoins.isEmpty && event.coins.length <= 1) {
        return emit(
          PortfolioProfitLossChartUnsupported(
            selectedPeriod: event.selectedPeriod,
          ),
        );
      }

      await _getProfitLossChart(event, supportedCoins, useCache: true)
          .then(emit.call)
          .catchError((Object error, StackTrace stackTrace) {
        const errorMessage = 'Failed to load CACHED portfolio profit/loss';
        _log.warning(errorMessage, error, stackTrace);
        // ignore cached errors, as the periodic refresh attempts should recover
        // at the cost of a longer first loading time.
      });

      // Fetch the un-cached version of the chart to update the cache.
      await _sdk.waitForEnabledCoinsToPassThreshold(supportedCoins);
      final activeCoins = await _removeInactiveCoins(supportedCoins);
      if (activeCoins.isNotEmpty) {
        await _getProfitLossChart(event, activeCoins, useCache: false)
            .then(emit.call)
            .catchError((Object e, StackTrace s) {
          _log.severe('Failed to load uncached profit/loss chart', e, s);
          // Ignore un-cached errors, as a transaction loading exception should not
          // make the graph disappear with a load failure emit, as the cached data
          // is already displayed. The periodic updates will still try to fetch the
          // data and update the graph.
        });
      }
    } catch (error, stackTrace) {
      _log.shout('Failed to load portfolio profit/loss', error, stackTrace);
      // Don't emit an error state here, as the periodic refresh attempts should
      // recover at the cost of a longer first loading time.
    }

    await emit.forEach(
      Stream<Object?>.periodic(event.updateFrequency).asyncMap(
        (_) async => _getProfitLossChart(event, event.coins, useCache: false),
      ),
      onData: (ProfitLossState updatedChartState) => updatedChartState,
      onError: (e, s) {
        _log.shout('Failed to load portfolio profit/loss', e, s);
        return ProfitLossLoadFailure(
          error: TextError(error: 'Failed to load portfolio profit/loss'),
          selectedPeriod: event.selectedPeriod,
        );
      },
    );
  }

  Future<ProfitLossState> _getProfitLossChart(
    ProfitLossPortfolioChartLoadRequested event,
    List<Coin> coins, {
    required bool useCache,
  }) async {
    // Do not let exceptions stop the periodic updates. Let the periodic stream
    // retry on the next failure instead of exiting.
    try {
      final filteredChart = await _getSortedProfitLossChartForCoins(
        event,
        useCache: useCache,
      );
      final unCachedProfitIncrease = filteredChart.increase;
      final unCachedPercentageIncrease = filteredChart.percentageIncrease;
      return PortfolioProfitLossChartLoadSuccess(
        profitLossChart: filteredChart,
        totalValue: unCachedProfitIncrease,
        percentageIncrease: unCachedPercentageIncrease,
        coins: coins,
        fiatCurrency: event.fiatCoinId,
        selectedPeriod: event.selectedPeriod,
        walletId: event.walletId,
        isUpdating: false,
      );
    } catch (error, stackTrace) {
      _log.shout('Failed periodic profit/loss chart update', error, stackTrace);
      return state;
    }
  }

  Future<List<Coin>> _removeUnsupportedCons(
    List<Coin> walletCoins,
    String fiatCoinId,
  ) async {
    final coins = List<Coin>.of(walletCoins);
    for (final coin in coins) {
      final isCoinSupported = await _profitLossRepository.isCoinChartSupported(
        coin.id,
        fiatCoinId,
      );
      if (coin.isTestCoin || !isCoinSupported) {
        coins.remove(coin);
      }
    }
    return coins;
  }

  Future<void> _onPortfolioPeriodChanged(
    ProfitLossPortfolioPeriodChanged event,
    Emitter<ProfitLossState> emit,
  ) async {
    final eventState = state;
    if (eventState is! PortfolioProfitLossChartLoadSuccess) {
      return emit(
        PortfolioProfitLossChartLoadInProgress(
          selectedPeriod: event.selectedPeriod,
        ),
      );
    }

    emit(
      PortfolioProfitLossChartLoadSuccess(
        profitLossChart: eventState.profitLossChart,
        totalValue: eventState.totalValue,
        percentageIncrease: eventState.percentageIncrease,
        coins: eventState.coins,
        fiatCurrency: eventState.fiatCurrency,
        walletId: eventState.walletId,
        selectedPeriod: event.selectedPeriod,
        isUpdating: true,
      ),
    );

    add(
      ProfitLossPortfolioChartLoadRequested(
        coins: eventState.coins,
        fiatCoinId: eventState.fiatCurrency,
        selectedPeriod: event.selectedPeriod,
        walletId: eventState.walletId,
      ),
    );
  }

  Future<ChartData> _getSortedProfitLossChartForCoins(
    ProfitLossPortfolioChartLoadRequested event, {
    bool useCache = true,
  }) async {
    if (!await _sdk.auth.isSignedIn()) {
      _log.warning('Error loading profit/loss chart: User is not signed in');
      return ChartData.empty();
    }

    final chartsList = await Future.wait(
      event.coins.map((coin) async {
        // Catch any errors and return an empty chart to prevent a single coin
        // from breaking the entire portfolio chart.
        try {
          final profitLosses = await _profitLossRepository.getProfitLoss(
            coin.id,
            event.fiatCoinId,
            event.walletId,
            useCache: useCache,
          );

          final firstNonZeroProfitLossIndex =
              profitLosses.indexWhere((element) => element.profitLoss != 0);
          if (firstNonZeroProfitLossIndex == -1) {
            _log.info('No non-zero profit/loss data found for ${coin.abbr}');
            return ChartData.empty();
          }

          final nonZeroProfitLosses =
              profitLosses.sublist(firstNonZeroProfitLossIndex);
          return nonZeroProfitLosses.toChartData();
        } catch (e, s) {
          final cached = useCache ? 'cached' : 'uncached';
          _log.severe('Failed to load $cached profit/loss: ${coin.abbr}', e, s);
          return ChartData.empty();
        }
      }),
    );

    chartsList.removeWhere((element) => element.isEmpty);
    return Charts.merge(chartsList)..sort((a, b) => a.x.compareTo(b.x));
  }

  Future<List<Coin>> _removeInactiveCoins(List<Coin> coins) async {
    final coinsCopy = List<Coin>.of(coins);
    final activeCoins = await _sdk.assets.getActivatedAssets();
    final activeCoinsMap = activeCoins.map((e) => e.id).toSet();
    for (final coin in coins) {
      if (!activeCoinsMap.contains(coin.id)) {
        coinsCopy.remove(coin);
      }
    }
    return coinsCopy;
  }
}
