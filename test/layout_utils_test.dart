import 'package:flutter_test/flutter_test.dart';
import 'package:the_art_of_the_break_widgetbook/autovio/layout_utils.dart';

void main() {
  test('breakNicely', () {
    expect(
        breakNicely('Hintergrundaktualisierung ist deaktiviert').replaceAll('\u00A0', '_'),
        equals('Hintergrundaktualisierung ist_deaktiviert')
    );
  });
}