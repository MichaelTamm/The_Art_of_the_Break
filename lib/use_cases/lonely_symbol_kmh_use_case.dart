import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';
import '../widgets/split_screen.dart';

@UseCase(name: 'Lonely Symbol km/h', type: The_Art_of_the_Break)
Widget buildLonelySymbolKmhUseCase(BuildContext context) {
  final cardWidth = context.knobs.double.slider(
    label: 'Card width',
    initialValue: 320,
    min: 200,
    max: 400,
  );
  final cardHeight = context.knobs.double.slider(
    label: 'Card height',
    initialValue: 300,
    min: 100,
    max: 400,
  );

  var question =
      'You are travelling at 100 km/h, have a reaction time of 1 second, and brake normally. What is the stopping distance according to the rule of thumb?';
  question = question.replaceAllMapped(
    RegExp('([0-9]) '),
    (match) => '${match.group(1)}\u{00A0}',
  );

  var text1 = question;
  var text2 = question.replaceAll('km/h', 'km/\u{2060}h');

  return Column(
    children: [
      SizedBox(height: 32),
      DartCode('''
  var question = 'You are travelling at 100 km/h, have a reaction time of 1 second, ...';
  question = question.replaceAllMapped( RegExp('([0-9]) '), (match) => '\${match.group(1)}\\u{00A0}');

  var text1 = question;
  var text2 = question.replaceAll('km/h', 'km/\\u{2060}h');

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
