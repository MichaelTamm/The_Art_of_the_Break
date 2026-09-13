import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_art_of_the_break_widgetbook/auto_hyphenate.dart';

void main() {
  testWidgets('de', (_) async {
    await initAutoHyphenate(const Locale('de'));
    expect(
      'Damit deine privaten Termine berücksichtigt werden können, wenn Fahrschüler Fahrstunden buchen, ...'
          .autoHyphenate()
          .replaceAll('\u00AD', '(-)'),
      equals(
        'Da(-)mit dei(-)ne pri(-)va(-)ten Ter(-)mi(-)ne be(-)rück(-)sich(-)tigt wer(-)den kön(-)nen, wenn Fahr(-)schü(-)ler Fahr(-)stun(-)den bu(-)chen, ...',
      ),
    );
  });
}
