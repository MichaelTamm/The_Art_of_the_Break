import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'autovio_colors.dart';

const poppins = GoogleFonts.poppins;

const labelBigFontSize = 16.0;
const bodyFontSize = 16.0;
const defaultFontSize = 16.0;

const regular = FontWeight.w400;
const semibold = FontWeight.w600;

final labelBigSemibold = poppins(fontSize: labelBigFontSize, fontWeight: semibold, height: 20 / 16);
final labelBigSemiboldBlack = labelBigSemibold.copyWith(color: AutovioColors.black);
final labelBigSemiboldGrey = labelBigSemibold.copyWith(color: AutovioColors.grey);

final bodyBlack = poppins(color: AutovioColors.black, fontSize: bodyFontSize, fontWeight: regular, height: 24 / 16);
final bodyGrey = poppins(color: AutovioColors.grey, fontSize: bodyFontSize, fontWeight: regular, height: 24 / 16);

final buttonTextStyle = _always(poppins(fontSize: defaultFontSize, fontWeight: semibold));
const buttonSize = 60.0;
const smallButtonSize = 40.0;

final autovioTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(foregroundColor: AutovioColors.white, backgroundColor: AutovioColors.black)
        .copyWith(
          textStyle: buttonTextStyle,
          shape: _always(RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonSize / 2))),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AutovioColors.greyLight;
            }
            return AutovioColors.black;
          }),
          minimumSize: _always(Size.square(buttonSize)),
          shadowColor: _always(Colors.transparent),
        ),
  ),
);

final smallButtonTextStyle = _always(poppins(fontSize: 14.0, fontWeight: semibold));

final smallButtonStyle = autovioTheme.elevatedButtonTheme.style!.copyWith(
  textStyle: smallButtonTextStyle,
  shape: _always(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  minimumSize: _always(Size(smallButtonSize * 2.5, smallButtonSize)),
);

WidgetStateProperty<T> _always<T>(T value) => WidgetStatePropertyAll(value);
