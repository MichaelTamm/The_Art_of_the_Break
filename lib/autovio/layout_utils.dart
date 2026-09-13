import 'package:flutter/material.dart';

extension LayoutUtilsExtension on Widget {
  Padding withPadding(double value) => Padding(padding: EdgeInsets.all(value), child: this);

  Padding withPaddingFromLTRB(double left, double top, double right, double bottom) =>
      Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);

  Padding withHorizontalPadding(double value) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Padding withVerticalPadding(double value) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );

  Padding withLeftPadding(double value) =>
      Padding(
        padding: EdgeInsets.only(left: value),
        child: this,
      );

  Padding withRightPadding(double value) =>
      Padding(
        padding: EdgeInsets.only(right: value),
        child: this,
      );

  Widget withTopPadding(double value) {
    if (value == 0) {
      return this;
    }
    return Padding(
      padding: EdgeInsets.only(top: value),
      child: this,
    );
  }

  Padding withBottomPadding(double value) =>
      Padding(
        padding: EdgeInsets.only(bottom: value),
        child: this,
      );
}

SizedBox spacer([double spacing = 10]) => SizedBox(width: spacing, height: spacing);

/// Prevent a line break before the last word if it has just a few characters' ...
String breakNicely(String s) {
  final n = s.length;
  // Find the first space character after the middle of s ...
  final i = s.indexOf(' ', (s.length + 1) ~/ 2);
  if (i < 0) {
    // There is no space character in the second half of s ...
    return s;
  }
  // Replace all space characters *after* the space character, where the line break should be,
  // with non-breakable space characters ...
  final j = s.lastIndexOf(' ', i - 1);
  if (j > 0) {
    // If we do not replace the space character at `i`, that's where the line break will be ...
    final d1 = (i - (n - (i + 1))).abs();
    // If we do replace the space character at `i`, the line break will be at `j` ...
    final d2 = (j - (n - (j + 1))).abs();
    // We prefer a longer first line unless the line length difference when breaking at `j`
    // is much less than the the line length difference when breaking at `i` ...
    if (d2 * 3 <= d1) {
      return s.substring(0, i) + s.substring(i).replaceAll(' ', '\u00A0').replaceAll('\u00AD', '');
    }
  }
  return s.substring(0, i + 1) + s.substring(i + 1).replaceAll(' ', '\u00A0').replaceAll('\u00AD', '');
}

