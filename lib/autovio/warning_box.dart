import 'package:flutter/material.dart';

import 'autovio_colors.dart';
import 'autovio_styles.dart';
import 'layout_utils.dart';

class WarningBox extends StatelessWidget {
  const WarningBox({required this.buildTitle, required this.buildText, this.button, super.key});

  final Widget Function(TextStyle) buildTitle;
  final Widget Function(TextStyle) buildText;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    final button = this.button?.withTopPadding(15);
    return Container(
      decoration: BoxDecoration(
        color: AutovioColors.orangeUltraLight,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildTitle(labelBigSemiboldBlack)),
                spacer(10),
                Icon(Icons.warning_amber_rounded, color: AutovioColors.orange),
              ],
            ),
            spacer(15),
            buildText(bodyBlack),
            if (button != null)
              Row(
                children: [
                  Expanded(child: Container()),
                  button,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
