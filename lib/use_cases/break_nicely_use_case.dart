import 'package:flutter/material.dart';
import 'package:the_art_of_the_break_widgetbook/autovio/layout_utils.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';

@UseCase(name: 'Break Nicely', type: The_Art_of_the_Break)
Widget buildCrossAxisAlignUseCase(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Lorem ipsum dolor sit amet');
  final cardWidth = context.knobs.double.slider(label: 'Card width', initialValue: 500, min: 200, max: 800);
  final fontSize = context.knobs.double.slider(label: 'Font size', initialValue: 40, min: 20, max: 100);
  final i = title.indexOf(' ');
  final titleAsDartString = "'${i < 0 ? title : title.substring(0, i + 1)}...'";

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 32),
      DartCode('Text($titleAsDartString)'),
      SizedBox(height: 8),
      _ExampleCard(title, fontSize, cardWidth),
      Expanded(child: SizedBox.shrink()),
      DartCode('Text(breakNicely1($titleAsDartString))'),
      SizedBox(height: 8),
      _ExampleCard(breakNicely1(title), fontSize, cardWidth),
      Expanded(child: SizedBox.shrink()),
      DartCode('Text(breakNicely2($titleAsDartString))'),
      SizedBox(height: 8),
      _ExampleCard(breakNicely2(title), fontSize, cardWidth),
      SizedBox(height: 32),
    ],
  );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard(this.title, this.fontSize, this.cardWidth);

  final String title;
  final double fontSize;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }
}
