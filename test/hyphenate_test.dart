import 'package:flutter_test/flutter_test.dart';
import 'package:hyphen/hyphen.dart';

void main() {
  testWidgets('de', (_) async {
    final de = await Hyphen.fromDictionaryPath('assets/hyph-de-1996.dic');
    expect(de.hyphenate('damit'), ['da', 'mit']);
    expect(de.hyphenate('diese'), ['die', 'se']);
    // expect(de.hyphenate('Hintergrundaktualisierung'), ['Hin', 'ter', 'grund', 'ak', 'tu', 'a', 'li', 'sie', 'rung']);
    expect(de.hyphenate('Hintergrundaktualisierung'), ['Hin', 'ter', 'grund', 'ak', 'tua', 'li', 'sie', 'rung']);
    expect(de.hyphenate('Fahrschüler'), ['Fahr', 'schü', 'ler']);
  });
}