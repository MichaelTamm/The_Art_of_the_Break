import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const String _shy = '\u00AD';
const String _nbsp = '\u00A0';

/// An alternative to the standard Flutter [Text] widgets,
/// which handles and displays soft hyphens ('\u00AD') correctly.
/// Furthermore every '_' character is treated as a non breaking space ('\u00A0')
/// and every occurrence of '(-)' is treated as a soft hyphen too.
class SoftHyphenText2 extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;

  SoftHyphenText2(String text, {this.style, this.textAlign = TextAlign.start, this.maxLines, super.key})
    : text = text.replaceAll('(-)', _shy).replaceAll('_', _nbsp);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final textScaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return _SoftHyphenTextPainter(
          text: text,
          style: effectiveStyle,
          textAlign: textAlign,
          textScaler: textScaler,
          maxLines: maxLines,
          constraints: constraints,
        );
      },
    );
  }
}

class _SoftHyphenTextPainter extends HookWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextScaler textScaler;
  final int? maxLines;
  final double maxWidth;
  final TextPainter textPainter;

  _SoftHyphenTextPainter({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.textScaler,
    this.maxLines,
    required BoxConstraints constraints,
  }) : textPainter = TextPainter(
         textDirection: TextDirection.ltr,
         textAlign: textAlign,
         textScaler: textScaler,
         maxLines: 1,
       ),
       maxWidth = constraints.maxWidth;

  @override
  Widget build(BuildContext context) {
    try {
      final maxLines = this.maxLines;
      final paragraphs = text.split('\n');
      final layout = <List<String>>[];
      var remainingLines = maxLines;
      for (final paragraph in paragraphs) {
        final lines = _processParagraph(paragraph, maxWidth);
        layout.add(lines);
        if (remainingLines != null) {
          remainingLines -= lines.length;
          if (remainingLines <= 0) {
            break;
          }
        }
      }
      final lines = layout
          .expand((lines) {
            final indexOfLastLine = lines.length - 1;
            return lines.mapIndexed((index, line) {
              // justify all but the last line of a paragraph ...
              if (textAlign == TextAlign.justify && index < indexOfLastLine) {
                return _justify(line, style);
              }
              return Text(
                line,
                style: style,
                textAlign: textAlign,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
              );
            });
          })
          .toList(growable: false);
      return Column(
        crossAxisAlignment: switch (textAlign) {
          TextAlign.left => CrossAxisAlignment.start,
          TextAlign.right => CrossAxisAlignment.end,
          TextAlign.center => CrossAxisAlignment.center,
          TextAlign.justify => CrossAxisAlignment.stretch,
          TextAlign.start => CrossAxisAlignment.start,
          TextAlign.end => CrossAxisAlignment.end,
        },
        children: maxLines == null || lines.length <= maxLines ? lines : lines.sublist(0, maxLines),
      );
    } catch (error, stack) {
      debugPrintStack(
        label:
            '''
SoftHyphenText failed -- falling back to Text
  text: ${text.replaceAll(_nbsp, '_').replaceAll(_shy, '(-)')}
  maxWidth: $maxWidth,
  textScaler: $textScaler,
  error: $error,
''',
        stackTrace: stack,
      );
      return Text(text.replaceAll(_shy, ''), style: style, textAlign: textAlign, maxLines: maxLines);
    }
  }

  List<String> _processParagraph(String paragraph, double maxWidth) {
    paragraph = _normalize(paragraph);
    if (paragraph.isEmpty) {
      return [''];
    }
    final result = <String>[];
    var processed = '';
    var lastFittingCandidate = '';
    var remaining = paragraph;
    for (;;) {
      var i = _findNextSpaceOrHyphenOrSoftHyphen(remaining);
      while (i >= 0) {
        if (remaining[i] == ' ') {
          final candidate = processed + remaining.substring(0, i);
          if (_fitsInOneLine(candidate, style, textPainter, maxWidth)) {
            processed += remaining.substring(0, i + 1);
            lastFittingCandidate = candidate;
            remaining = remaining.substring(i + 1);
          } else {
            if (processed.isEmpty) {
              throw Exception('Word too long: $candidate -- add some soft hyphens');
            }
            break;
          }
        } else if (remaining[i] == '-') {
          final candidate = processed + remaining.substring(0, i + 1);
          if (_fitsInOneLine(candidate, style, textPainter, maxWidth)) {
            processed += remaining.substring(0, i + 1);
            lastFittingCandidate = candidate;
            remaining = remaining.substring(i + 1);
          } else {
            if (processed.isEmpty) {
              throw Exception('Word too long: $candidate -- add some soft hyphens');
            }
            break;
          }
        } else if (remaining[i] == _shy) {
          final candidate = '$processed${remaining.substring(0, i)}-';
          if (_fitsInOneLine(candidate, style, textPainter, maxWidth)) {
            processed += remaining.substring(0, i);
            lastFittingCandidate = candidate;
            remaining = remaining.substring(i + 1);
          } else {
            if (processed.isEmpty) {
              throw Exception('Prefix too long: $candidate -- add some more soft hyphens');
            }
            break;
          }
        } else {
          // Should never happen.
          throw Exception('Unexpected remaining[i]: ${remaining[i]}');
        }
        i = _findNextSpaceOrHyphenOrSoftHyphen(remaining);
      }
      if (i < 0) {
        final candidate = processed + remaining;
        if (_fitsInOneLine(candidate, style, textPainter, maxWidth)) {
          result.add(candidate);
        } else {
          result
            ..add(lastFittingCandidate)
            ..add(remaining);
        }
        return result;
      } else {
        result.add(lastFittingCandidate);
        processed = '';
      }
    }
  }

  String _normalize(String s) {
    s = s.replaceAll(_nbsp, '_');
    while (s.isNotEmpty && (s[0].isWhitespace || s[0] == _shy)) {
      s = s.substring(1);
    }
    return s.replaceAll(RegExp(r'\s+'), ' ').trimRight().replaceAll('_', _nbsp);
  }

  int _findNextSpaceOrHyphenOrSoftHyphen(String s, [int start = 0]) {
    final indexOfNextSpace = s.indexOf(' ', start);
    final indexOfNextHyphen = s.indexOf('-', start);
    final indexOfNextSoftHyphen = s.indexOf(_shy, start);
    final a = [
      if (indexOfNextSpace >= 0) indexOfNextSpace,
      if (indexOfNextHyphen >= 0) indexOfNextHyphen,
      if (indexOfNextSoftHyphen >= 0) indexOfNextSoftHyphen,
    ];
    return a.isEmpty ? -1 : a.reduce(min);
  }

  bool _fitsInOneLine(String text, TextStyle style, TextPainter textPainter, double maxWidth) {
    textPainter
      ..text = TextSpan(text: text, style: style)
      ..layout(maxWidth: maxWidth);
    return !textPainter.didExceedMaxLines && textPainter.width < maxWidth;
  }
}

extension on String {
  bool get isWhitespace => isNotEmpty && trim().isEmpty;
}

Widget _justify(String line, TextStyle style) {
  final words = line.split(RegExp(r'\s'));
  final maxIndex = words.length - 1;
  return Row(
    crossAxisAlignment: .baseline,
    textBaseline: .alphabetic,
    children: words
        .mapIndexed<Widget>(
          (index, word) => Text(
            word,
            style: style,
            textAlign: index == 0
                ? TextAlign.start
                : index == maxIndex
                ? TextAlign.end
                : TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        )
        .intersperse(Expanded(child: SizedBox.shrink()))
        .toList(growable: false),
  );
}

extension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) convert) sync* {
    var index = 0;
    for (var element in this) {
      yield convert(index++, element);
    }
  }

  Iterable<T> intersperse(T separator) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }
}
