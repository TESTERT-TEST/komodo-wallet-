import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:komodo_ui/komodo_ui.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

class DexListFilterCoinMobile extends StatelessWidget {
  const DexListFilterCoinMobile({
    Key? key,
    required this.label,
    required this.coinAbbr,
    required this.showCoinList,
  }) : super(key: key);
  final String label;
  final String? coinAbbr;
  final VoidCallback showCoinList;

  @override
  Widget build(BuildContext context) {
    final String? abbr = coinAbbr;
    final ThemeData themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: themeData.inputDecorationTheme.labelStyle?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        InkWell(
          radius: 18,
          onTap: showCoinList,
          child: Container(
            constraints: const BoxConstraints.tightFor(width: double.infinity),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: themeData.inputDecorationTheme.fillColor,
            ),
            child: Row(
              children: [
                if (abbr != null) AssetIcon.ofTicker(abbr),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    innerText,
                    style: themeData.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.expand_more,
                    color: themeData.inputDecorationTheme.labelStyle?.color)
              ],
            ),
          ),
        ),
      ],
    );
  }

  String get innerText {
    return coinAbbr ?? LocaleKeys.exchangeCoin.tr();
  }
}
