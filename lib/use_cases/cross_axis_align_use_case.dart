import 'package:flutter/material.dart';
import 'package:the_art_of_the_break_widgetbook/autovio/autovio_colors.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';

@UseCase(name: 'Cross Axis Align', type: The_Art_of_the_Break)
Widget buildCrossAxisAlignUseCase(BuildContext context) {

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 32),
      DartCode('Row(crossAxisAlignment: .start, ...)'),
      SizedBox(height: 8),
      _ExampleRow(CrossAxisAlignment.start),
      Expanded(child: SizedBox.shrink()),
      DartCode('Row(crossAxisAlignment: .center, ...)'),
      SizedBox(height: 8),
      _ExampleRow(CrossAxisAlignment.center),
      Expanded(child: SizedBox.shrink()),
      DartCode('Row(crossAxisAlignment: .baseline, ...)'),
      SizedBox(height: 8),
      _ExampleRow(CrossAxisAlignment.baseline),
      Expanded(child: SizedBox.shrink()),
      DartCode('Row(crossAxisAlignment: .end, ...)'),
      SizedBox(height: 8),
      _ExampleRow(CrossAxisAlignment.end),
      SizedBox(height: 32),
    ],
  );
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow(this.crossAxisAlignment);

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 450,
        color: AutovioColors.greyLight,
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          textBaseline: .alphabetic,
          children: [
            SizedBox(width: 8),
            Text('left', style: TextStyle(fontSize:  48, fontWeight: .bold)),
            Expanded(child: SizedBox.shrink()),
            Text('center', style: TextStyle(fontSize: 64, fontWeight: .bold)),
            Expanded(child: SizedBox.shrink()),
            Text('right', style: TextStyle(fontSize: 32, fontWeight: .bold)),
            SizedBox(width: 8),
          ],
        )
    );
  }
}
