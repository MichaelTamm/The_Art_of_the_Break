//Inspired by Textless (https://github.com/sooxt98/textless)
//
//MIT License
//
//Copyright (c) 2021 sooxt98
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import 'package:flutter/material.dart';

import 'autovio_styles.dart' as styles;

class AutovioThemedText extends StatelessWidget {
  const AutovioThemedText({required this.data, required this.style, this.extra, super.key});

  final String data;
  final TextStyle style;
  final Map<String, dynamic>? extra;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      overflow: extra?['overflow'] as TextOverflow?,
      maxLines: extra?['maxLine'] as int?,
      softWrap: extra?['softWrap'] as bool?,
      textAlign: extra?['textAlign'] as TextAlign?,
    );
  }

  AutovioThemedText textless(Map<String, dynamic> extra) => AutovioThemedText(data: data, style: style, extra: {...?this.extra, ...extra});

  AutovioThemedText get overflowVisible => textless({'overflow': TextOverflow.visible});
  AutovioThemedText get overflowClip => textless({'overflow': TextOverflow.clip});
  AutovioThemedText get overflowEllipsis => textless({'overflow': TextOverflow.ellipsis});
  AutovioThemedText get overflowFade => textless({'overflow': TextOverflow.fade});

  AutovioThemedText maxLine(int v) => textless({'maxLine': v});
  AutovioThemedText maxLines(int v) => textless({'maxLine': v});

  // ignore: avoid_positional_boolean_parameters
  AutovioThemedText softWrap(bool v) => textless({'softWrap': v});

  AutovioThemedText get alignLeft => textless({'textAlign': TextAlign.left});
  AutovioThemedText get alignRight => textless({'textAlign': TextAlign.right});
  AutovioThemedText get alignCenter => textless({'textAlign': TextAlign.center});
  AutovioThemedText get alignJustify => textless({'textAlign': TextAlign.justify});
  AutovioThemedText get alignStart => textless({'textAlign': TextAlign.start});
  AutovioThemedText get alignEnd => textless({'textAlign': TextAlign.end});
}

extension AutovioThemedTextStyle on AutovioThemedText {}

extension AutovioTextLess on String {
  AutovioThemedText get text => AutovioThemedText(data: this, style: const TextStyle());
  AutovioThemedText get labelBigSemiboldGrey => AutovioThemedText(data: this, style: styles.labelBigSemiboldGrey);
}
