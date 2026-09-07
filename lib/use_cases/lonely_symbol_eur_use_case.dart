import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';
import '../widgets/split_screen.dart';

@UseCase(name: 'Lonely Symbol €', type: The_Art_of_the_Break)
Widget buildLonelySymbolEurUseCase(BuildContext context) {
  final cardWidth = context.knobs.double.slider(
    label: 'Card width',
    initialValue: 240,
    min: 200,
    max: 300,
  );
  final cardHeight = context.knobs.double.slider(
    label: 'Card height',
    initialValue: 200,
    min: 100,
    max: 300,
  );

  NumberFormat decimalFormat = NumberFormat.decimalPatternDigits(
    locale: 'de',
    decimalDigits: 2,
  );
  NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'de',
    decimalDigits: 2,
    symbol: '€',
  );

  final text1 =
      'Marta wird die Differenz von ${decimalFormat.format(53.33)} € in Rechnung gestellt.';
  final text2 =
      'Marta wird die Differenz von ${currencyFormat.format(53.33)} in Rechnung gestellt.';

  return Column(
    children: [
      SizedBox(height: 32),
      DartCode('''
  NumberFormat decimalFormat = NumberFormat.decimalPatternDigits(
    locale: 'de',
    decimalDigits: 2,
  );
  NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'de',
    decimalDigits: 2,
    symbol: '€',
  );

  final text1 =
      'Marta wird die Differenz von \${decimalFormat.format(53.33)} € in Rechnung gestellt.';
  final text2 =
      'Marta wird die Differenz von \${currencyFormat.format(53.33)} in Rechnung gestellt.';
'''),
      SizedBox(height: 32),
      Expanded(
        child: SplitScreen(
          childSize: Size(cardWidth, cardHeight),
          childAlignment: .topCenter,
          children: [_ExampleCard(text1), _ExampleCard(text2)],
        ),
      ),
    ],
  );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(text, style: TextStyle(fontSize: 20))),
          ],
        ),
      ),
    );
  }
}
