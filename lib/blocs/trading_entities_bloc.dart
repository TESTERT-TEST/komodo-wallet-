import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/blocs/bloc_base.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/cancel_order/cancel_order_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/recover_funds_of_swap/recover_funds_of_swap_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/recover_funds_of_swap/recover_funds_of_swap_response.dart';
import 'package:web_dex/model/my_orders/my_order.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/services/orders_service/my_orders_service.dart';
import 'package:web_dex/shared/utils/utils.dart';

class TradingEntitiesBloc implements BlocBase {
  TradingEntitiesBloc(
    KomodoDefiSdk kdfSdk,
    Mm2Api mm2Api,
    MyOrdersService myOrdersService,
  )   : _mm2Api = mm2Api,
        _myOrdersService = myOrdersService,
        _kdfSdk = kdfSdk;

  final KomodoDefiSdk _kdfSdk;
  final MyOrdersService _myOrdersService;
  final Mm2Api _mm2Api;
  StreamSubscription<KdfUser?>? _authModeListener;
  List<MyOrder> _myOrders = [];
  List<Swap> _swaps = [];
  Timer? timer;

  final StreamController<List<MyOrder>> _myOrdersController =
      StreamController<List<MyOrder>>.broadcast();
  Sink<List<MyOrder>> get _inMyOrders => _myOrdersController.sink;
  Stream<List<MyOrder>> get outMyOrders => _myOrdersController.stream;
  List<MyOrder> get myOrders => _myOrders;
  set myOrders(List<MyOrder> orderList) {
    orderList.sort((first, second) => second.createdAt - first.createdAt);
    _myOrders = orderList;
    _inMyOrders.add(_myOrders);
  }

  final StreamController<List<Swap>> _swapsController =
      StreamController<List<Swap>>.broadcast();
  Sink<List<Swap>> get _inSwaps => _swapsController.sink;
  Stream<List<Swap>> get outSwaps => _swapsController.stream;
  List<Swap> get swaps => _swaps;
  set swaps(List<Swap> swapList) {
    swapList.sort((first, second) =>
        (second.myInfo?.startedAt ?? 0) - (first.myInfo?.startedAt ?? 0));
    _swaps = swapList;
    _inSwaps.add(_swaps);
  }

  Future<void> fetch() async {
    if (!await _kdfSdk.auth.isSignedIn()) return;

    myOrders = await _myOrdersService.getOrders() ?? [];
    swaps = await getRecentSwaps(MyRecentSwapsRequest()) ?? [];
  }

  @override
  void dispose() {
    _authModeListener?.cancel();
  }

  void runUpdate() {
    bool updateInProgress = false;

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (updateInProgress) return;
      // TODO!: do not run for hidden login or HW

      updateInProgress = true;
      await fetch();
      updateInProgress = false;
    });
  }

  Future<String?> cancelOrder(String uuid) async {
    final Map<String, dynamic> response =
        await _mm2Api.cancelOrder(CancelOrderRequest(uuid: uuid));
    return response['error'];
  }

  bool isCoinBusy(String coin) {
    return (_swaps
                .where((swap) => !swap.isCompleted)
                .where((swap) => swap.sellCoin == coin || swap.buyCoin == coin)
                .toList()
                .length +
            _myOrders
                .where((order) => order.base == coin || order.rel == coin)
                .toList()
                .length) >
        0;
  }

  bool hasActiveSwap(String coin) {
    return _swaps
        .where((swap) => !swap.isCompleted)
        .any((swap) => swap.sellCoin == coin || swap.buyCoin == coin);
  }

  bool hasOpenOrders(String coin) {
    return _myOrders.any((order) => order.base == coin || order.rel == coin);
  }

  int openOrdersCount(String coin) {
    return _myOrders
        .where((order) => order.base == coin || order.rel == coin)
        .length;
  }

  Future<void> cancelOrdersForCoin(String coin) async {
    final futures = _myOrders
        .where((o) => o.base == coin || o.rel == coin)
        .map((o) => cancelOrder(o.uuid));
    await Future.wait(futures);
  }

  double getPriceFromAmount(Rational sellAmount, Rational buyAmount) {
    final sellDoubleAmount = sellAmount.toDouble();
    final buyDoubleAmount = buyAmount.toDouble();

    if (sellDoubleAmount == 0 || buyDoubleAmount == 0) return 0;
    return buyDoubleAmount / sellDoubleAmount;
  }

  String getTypeString(bool isTaker) =>
      isTaker ? LocaleKeys.takerOrder.tr() : LocaleKeys.makerOrder.tr();

  Swap? getSwap(String uuid) =>
      swaps.firstWhereOrNull((swap) => swap.uuid == uuid);

  double getProgressFillSwap(MyOrder order) {
    final List<Swap> swaps = (order.startedSwaps ?? [])
        .map((id) => getSwap(id))
        .whereType<Swap>()
        .toList();
    final double swapFill = swaps.fold(0,
        (previousValue, swap) => previousValue + (swap.myInfo?.myAmount ?? 0));
    return swapFill / order.baseAmount.toDouble();
  }

  Future<void> cancelAllOrders() async {
    final futures = myOrders.map((o) => cancelOrder(o.uuid));
    Future.wait(futures);
  }

  Future<List<Swap>?> getRecentSwaps(MyRecentSwapsRequest request) async {
    final MyRecentSwapsResponse? response =
        await _mm2Api.getMyRecentSwaps(request);
    if (response == null) {
      return null;
    }

    return response.result.swaps;
  }

  Future<RecoverFundsOfSwapResponse?> recoverFundsOfSwap(String uuid) async {
    final RecoverFundsOfSwapRequest request =
        RecoverFundsOfSwapRequest(uuid: uuid);
    final RecoverFundsOfSwapResponse? response =
        await _mm2Api.recoverFundsOfSwap(request);
    if (response != null) {
      log(
        response.toJson().toString(),
        path: 'swaps_service => recoverFundsOfSwap',
      );
    }
    return response;
  }

  Future<Rational?> getMaxTakerVolume(String coinAbbr) async {
    final MaxTakerVolResponse? response =
        await _mm2Api.getMaxTakerVolume(MaxTakerVolRequest(coin: coinAbbr));
    if (response == null) {
      return null;
    }

    return fract2rat(response.result.toJson());
  }
}
