import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';
import '../widgets/split_screen.dart';

@UseCase(name: 'Text Overflow', type: The_Art_of_the_Break)
Widget buildTextOverflowUseCase(BuildContext context) {
  final cardWidth = context.knobs.double.slider(
    label: 'Card width',
    initialValue: 180,
    min: 80,
    max: 200,
  );
  final cardHeight = context.knobs.double.slider(
    label: 'Card height',
    initialValue: 160,
    min: 80,
    max: 300,
  );
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Dummy Title',
  );
  final titleWithZWSP = Characters(title).toList().join('\u{200B}');
  final titleMaxLines = context.knobs.object.dropdown<String>(
    label: 'Title max lines',
    options: const ['null', '1', '2'],
    initialOption: 'null',
  );
  final maxLines = titleMaxLines == 'null' ? null : int.parse(titleMaxLines);
  final showZWSPHack = context.knobs.boolean(
    label: 'Show ZWSP hack',
    initialValue: false,
  );

  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: .bottomCenter,
                child: DartCode('overflow: .clip'),
              ),
            ),
            Expanded(
              child: Align(
                alignment: .bottomCenter,
                child: DartCode('overflow: .fade'),
              ),
            ),
            Expanded(
              child: Align(
                alignment: .bottomCenter,
                child: DartCode('overflow: .ellipsis'),
              ),
            ),
            Expanded(
              child: Align(
                alignment: .bottomCenter,
                child: DartCode('overflow: .visible'),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
      Expanded(
        child: SplitScreen(
          childSize: Size(cardWidth, cardHeight),
          childAlignment: .topCenter,
          children: [
            _ExampleCard(title: title, overflow: .clip, maxLines: maxLines),
            _ExampleCard(title: title, overflow: .fade, maxLines: maxLines),
            _ExampleCard(title: title, overflow: .ellipsis, maxLines: maxLines),
            _ExampleCard(title: title, overflow: .visible, maxLines: maxLines),
          ],
        ),
      ),
      if (showZWSPHack) ...[
        SizedBox(height: 8),
        Center(child: DartCode("Characters(title).toList().join('\\u{200B}')")),
        SizedBox(height: 8),
        Expanded(
          child: SplitScreen(
            childSize: Size(cardWidth, cardHeight),
            childAlignment: .topCenter,
            children: [
              _ExampleCard(
                title: titleWithZWSP,
                overflow: .clip,
                maxLines: maxLines,
              ),
              _ExampleCard(
                title: titleWithZWSP,
                overflow: .fade,
                maxLines: maxLines,
              ),
              _ExampleCard(
                title: titleWithZWSP,
                overflow: .ellipsis,
                maxLines: maxLines,
              ),
              _ExampleCard(
                title: titleWithZWSP,
                overflow: .visible,
                maxLines: maxLines,
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.maxLines,
    this.overflow,
  });

  final String title;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: overflow,
              maxLines: maxLines,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
