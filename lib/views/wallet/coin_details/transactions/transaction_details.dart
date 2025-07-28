import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';
import 'package:komodo_ui/utils.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/coins_bloc/coins_repo.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/formatters.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/copied_text.dart';
import 'package:web_dex/views/wallet/common/address_copy_button.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({
    Key? key,
    required this.transaction,
    required this.onClose,
    required this.coin,
  }) : super(key: key);

  final Transaction transaction;
  final void Function() onClose;
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.only(
      top: isMobile ? 16 : 0,
      left: 16,
      right: 16,
      bottom: isMobile ? 20 : 30,
    );
    final scrollController = ScrollController();

    return DexScrollbar(
      isMobile: isMobile,
      scrollController: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 26, 0, 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: theme.custom.subCardBackgroundColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.transactionDetailsTitle.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AssetIcon.ofTicker(coin.abbr, size: 32),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: SelectableText(coin.name),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildBalanceChanges(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.date.tr(),
                      value: formatTransactionDateTime(transaction),
                      hasBackground: true,
                    ),
                    _buildFee(context),
                    _buildMemo(context),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.confirmations.tr(),
                      value: transaction.confirmations.toString(),
                      hasBackground: true,
                    ),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.blockHeight.tr(),
                      value: transaction.blockHeight.toString(),
                    ),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.transactionHash.tr(),
                      value: transaction.txHash ?? '',
                      isCopied: true,
                      isTruncated: true,
                    ),
                    SizedBox(height: 16),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.from.tr(),
                      value: transaction.from.first,
                      isCopied: true,
                    ),
                    _buildSimpleData(
                      context,
                      title: LocaleKeys.to.tr(),
                      value: transaction.to.first,
                      isCopied: true,
                    ),
                    SizedBox(height: 16),
                    _buildControls(context, isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress(
    BuildContext context, {
    required String title,
    required String address,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title with fixed flex
          Expanded(
            flex: 2,
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          // Address and copy button
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: AutoScrollText(
                    text: address,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                AddressCopyButton(address: address),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddresses(bool isMobile, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddress(
            context,
            title: LocaleKeys.from.tr(),
            address: transaction.from.first,
          ),
          _buildAddress(
            context,
            title: LocaleKeys.to.tr(),
            address: transaction.to.first,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChanges(BuildContext context) {
    final String formatted = formatDexAmt(transaction.amount.toDouble().abs());
    final String sign = transaction.amount.toDouble() > 0 ? '+' : '-';
    final coinsBloc = RepositoryProvider.of<CoinsRepo>(context);
    final double? usd =
        coinsBloc.getUsdPriceByAmount(formatted, transaction.assetId.id);
    final String formattedUsd = formatAmt(usd ?? 0);
    final String value =
        '$sign $formatted ${Coin.normalizeAbbr(transaction.assetId.id)} (\$$formattedUsd)';

    return SelectableText(
      value,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 22,
            color: theme.custom.balanceColor,
          ),
    );
  }

  Widget _buildControls(BuildContext context, bool isMobile) {
    final double buttonHeight = isMobile ? 50 : 40;
    final double buttonWidth = isMobile ? 130 : 150;
    final double fontSize = isMobile ? 12 : 14;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UiPrimaryButton(
          width: buttonWidth,
          height: buttonHeight,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                color: theme.custom.defaultGradientButtonTextColor,
              ),
          onPressed: () {
            launchURLString(getTxExplorerUrl(coin, transaction.txHash ?? ''));
          },
          text: LocaleKeys.viewOnExplorer.tr(),
        ),
        SizedBox(width: isMobile ? 4 : 20),
        UiPrimaryButton(
          width: buttonWidth,
          height: buttonHeight,
          onPressed: onClose,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
          backgroundColor: theme.custom.lightButtonColor,
          text: LocaleKeys.done.tr(),
        ),
      ],
    );
  }

  Widget _buildFee(BuildContext context) {
    final coinsRepository = RepositoryProvider.of<CoinsRepo>(context);

    final String formattedFee = transaction.fee?.formatTotal() ?? '';
    final double? usd =
        coinsRepository.getUsdPriceByAmount(formattedFee, _feeCoin);
    final String formattedUsd = formatAmt(usd ?? 0);

    final String title = LocaleKeys.fees.tr();
    final String value =
        '- ${Coin.normalizeAbbr(_feeCoin)} $formattedFee (\$$formattedUsd)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 35),
              alignment: Alignment.centerLeft,
              child: SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.custom.decreaseColor,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemo(BuildContext context) {
    final String? memo = transaction.memo;
    if (memo == null || memo.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '${LocaleKeys.memo.tr()}: ',
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 35),
              alignment: Alignment.centerLeft,
              child: SelectableText(
                memo,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleData(
    BuildContext context, {
    required String title,
    required String value,
    bool hasBackground = false,
    bool isCopied = false,
    bool isTruncated = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerLeft,
              child: isCopied
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 340),
                      child: CopiedText(
                        copiedValue: value,
                        isTruncated: isTruncated,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        fontSize: 14,
                      ),
                    )
                  : SelectableText(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String get _feeCoin {
    return transaction.fee != null && transaction.fee!.coin.isNotEmpty
        ? transaction.fee!.coin
        : transaction.assetId.id;
  }
}
