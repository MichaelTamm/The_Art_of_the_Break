import 'dart:ui';

import 'package:hyphen/hyphen.dart';

Hyphen? _hyphen;

final RegExp _letterRegExp = RegExp(r'[\p{L}\p{M}]', unicode: true);

Future<void> initAutoHyphenate(Locale locale) async {
  if (locale.languageCode == 'de') {
    _hyphen = await Hyphen.fromDictionaryPath('assets/hyph-de-1996.dic');
  } else {
    throw UnimplementedError('Unsupported locale: $locale');
  }
}

extension AutoHyphenateExtension on String {
  String autoHyphenate() {
    final hyphen = _hyphen;
    if (hyphen == null) {
      throw StateError('initAutoHyphenate(...) has not been called yet.');
    }
    final sb = StringBuffer();
    var i = 0;
    while (i < length) {
      final char = this[i];
      if (!_letterRegExp.hasMatch(char)) {
        sb.write(char);
        i++;
        continue;
      }
      final start = i;
      i++;
      while (i < length && _letterRegExp.hasMatch(this[i])) {
        i++;
      }
      final word = substring(start, i);
      sb.write(hyphen.hyphenate(word).join('\u00AD'));
    }
    return sb.toString();
  }
}