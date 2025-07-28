// TODO: update [TransportError] and [BaseError] to either use SDK exceptions
// or to at least extend the Exception class
// ignore_for_file: only_throw_errors

import 'dart:convert';

import 'package:http/http.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:web_dex/mm2/mm2_api/rpc/errors.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/get_nft_list/get_nft_list_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/refresh_nft_metadata/refresh_nft_metadata_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/update_nft/update_nft_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/withdraw/withdraw_nft_request.dart';
import 'package:web_dex/mm2/rpc/nft_transaction/nft_transactions_request.dart';
import 'package:web_dex/model/nft.dart';
import 'package:web_dex/shared/constants.dart';

class Mm2ApiNft {
  Mm2ApiNft(this.call, this._sdk);

  final KomodoDefiSdk _sdk;
  final Future<JsonMap> Function(dynamic) call;
  final _log = Logger('Mm2ApiNft');

  Future<Map<String, dynamic>> updateNftList(
    List<NftBlockchains> chains,
  ) async {
    bool hasSuccess = false;
    for (final chain in chains) {
      try {
        await _enableNftChains([chain]);
        final List<String> nftChains = await getActiveNftChains([chain]);
        if (nftChains.isEmpty) continue;
        final request = UpdateNftRequest(chains: nftChains);
        await call(request);
        hasSuccess = true;
      } catch (e, s) {
        _log.shout(
            'Error updating nft for chain ${chain.toApiRequest()}', e, s);
      }
    }

    if (!hasSuccess) {
      return {
        'error': 'Failed to update NFTs for the provided chains',
      };
    }

    return {'result': 'ok'};
  }

  Future<Map<String, dynamic>> refreshNftMetadata({
    required String chain,
    required String tokenAddress,
    required String tokenId,
  }) async {
    try {
      final RefreshNftMetadataRequest request = RefreshNftMetadataRequest(
        chain: chain,
        tokenAddress: tokenAddress,
        tokenId: tokenId,
      );
      return await call(request);
    } catch (e, s) {
      _log.shout(e.toString(), e, s);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftList(List<NftBlockchains> chains) async {
    final List<NftBlockchains> enabledChains = [];
    for (final chain in chains) {
      try {
        await _enableNftChains([chain]);
        enabledChains.add(chain);
      } catch (e, s) {
        _log.shout('Failed to enable nft chain ${chain.toApiRequest()}', e, s);
      }
    }

    final List<String> nftChains = await getActiveNftChains(enabledChains);
    if (nftChains.isEmpty) {
      return {
        'error': 'Please ensure the NFT chain is activated and patiently await '
            'while your NFTs are loaded.',
      };
    }

    final List<dynamic> nfts = [];
    for (final chain in nftChains) {
      try {
        final request = GetNftListRequest(chains: [chain]);
        final JsonMap res = await call(request);
        final chainNfts = res['result'] != null
            ? List<dynamic>.from(res['result']['nfts'] as List? ?? [])
            : <dynamic>[];
        nfts.addAll(chainNfts);
      } catch (e, s) {
        _log.shout('Error getting nft list for chain $chain', e, s);
      }
    }

    return {
      'result': {
        'nfts': nfts,
      },
    };
  }

  Future<Map<String, dynamic>> withdraw(WithdrawNftRequest request) async {
    try {
      return await call(request);
    } catch (e, s) {
      _log.shout('Error withdrawing nft', e, s);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftTxs(
    NftTransactionsRequest request,
    bool withAdditionalInfo,
  ) async {
    try {
      final JsonMap json = await call(request);
      if (withAdditionalInfo) {
        final jsonUpdated = await const ProxyApiNft().addDetailsToTx(json);
        return jsonUpdated;
      }
      return json;
    } catch (e, s) {
      _log.shout('Error getting nft transactions', e, s);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftTxDetails(
    NftTxDetailsRequest request,
  ) async {
    try {
      final additionalTxInfo = await const ProxyApiNft()
          .getTxDetailsByHash(request.chain, request.txHash);
      return additionalTxInfo;
    } catch (e, s) {
      _log.shout('Error getting nft tx details', e, s);
      throw TransportError(message: e.toString());
    }
  }

  Future<List<String>> getActiveNftChains(List<NftBlockchains> chains) async {
    final List<Asset> apiCoins = await _sdk.assets.getActivatedAssets();
    final List<String> enabledCoinIds = apiCoins.map((c) => c.id.id).toList();
    _log.fine('enabledCoinIds: $enabledCoinIds');
    final List<String> nftCoins = chains.map((c) => c.coinAbbr()).toList();
    _log.fine('nftCoins: $nftCoins');
    final List<NftBlockchains> activeChains = chains
        .map((c) => c)
        .toList()
        .where((c) => enabledCoinIds.contains(c.coinAbbr()))
        .toList();
    _log.fine('activeChains: $activeChains');
    final List<String> nftChains =
        activeChains.map((c) => c.toApiRequest()).toList();
    _log.fine('nftChains: $nftChains');
    return nftChains;
  }

  Future<void> enableNft(Asset asset) async {
    final configSymbol = asset.id.symbol.configSymbol;
    final activationParams =
        NftActivationParams(provider: NftProvider.moralis());
    await _sdk.client.rpc.nft
        .enableNft(ticker: configSymbol, activationParams: activationParams);
  }

  Future<void> _enableNftChains(
    List<NftBlockchains> chains,
  ) async {
    final knownAssets = _sdk.assets.available;
    final activeAssets = await _sdk.assets.getActivatedAssets();
    final inactiveChains = chains
        .where(
          (chain) => !activeAssets
              .any((asset) => asset.id.id == chain.nftAssetTicker()),
        )
        .map(
          (chain) => knownAssets.values
              .firstWhere((asset) => asset.id.id == chain.nftAssetTicker()),
        )
        .toList();
    if (inactiveChains.isEmpty) {
      return;
    }

    for (final chain in inactiveChains) {
      await enableNft(chain);
    }
  }
}

class ProxyApiNft {
  const ProxyApiNft();
  static const _errorBaseMessage = 'ProxyApiNft API: ';
  Future<Map<String, dynamic>> addDetailsToTx(Map<String, dynamic> json) async {
    final transactions =
        List<dynamic>.from(json['result']['transfer_history'] as List? ?? []);
    final listOfAdditionalData = transactions
        .map(
          (tx) => {
            'blockchain': convertChainForProxy(tx['chain'] as String),
            'tx_hash': tx['transaction_hash'],
          },
        )
        .toList();

    final response = await Client().post(
      Uri.parse(txByHashUrl),
      body: jsonEncode(listOfAdditionalData),
    );
    final jsonBody = jsonDecode(response.body) as JsonMap;
    json['result']['transfer_history'] = transactions.map((element) {
      final txHash = element['transaction_hash'] as String?;
      final tx = jsonBody[txHash] as JsonMap?;
      if (tx != null) {
        element['confirmations'] = tx['confirmations'];
        element['fee_details'] = tx['fee_details'];
      }
      return element;
    }).toList();

    return json;
  }

  Future<Map<String, dynamic>> getTxDetailsByHash(
    String blockchain,
    String txHash,
  ) async {
    final listOfAdditionalData = [
      {
        'blockchain': convertChainForProxy(blockchain),
        'tx_hash': txHash,
      }
    ];
    final body = jsonEncode(listOfAdditionalData);
    try {
      final response = await Client().post(
        Uri.parse(txByHashUrl),
        body: body,
      );
      final jsonBody = jsonDecode(response.body) as JsonMap;
      return jsonBody[txHash] as JsonMap;
    } catch (e) {
      throw Exception(_errorBaseMessage + e.toString());
    }
  }

  String convertChainForProxy(String chain) {
    switch (chain) {
      case 'AVALANCHE':
        return 'avx';
      case 'BSC':
        return 'bnb';
      case 'ETH':
        return 'eth';
      case 'FANTOM':
        return 'ftm';
      case 'POLYGON':
        return 'plg';
    }

    throw UnimplementedError();
  }
}
