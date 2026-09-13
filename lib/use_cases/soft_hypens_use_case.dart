// ignore_for_file: constant_identifier_names

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:custom_text_engine/custom_text_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hyphenation/flutter_hyphenation.dart';
import 'package:hyphenatorx/widget/texthyphenated.dart';
import 'package:soft_hyphen_text/soft_hyphen_text.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../auto_hyphenate.dart';
import '../autovio/autovio_button.dart';
import '../autovio/autovio_styles.dart';
import '../autovio/layout_utils.dart';
import '../autovio/soft_hyphen_text2.dart';
import '../autovio/warning_box.dart';
import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';

enum _SoftHyphens { none, manual, auto }

enum _Package {
  flutter,
  auto_hyphenating_text,
  custom_text_engine,
  flutter_hyphenation,
  hyphenatorx,
  soft_hyphen_text,
  soft_hyphen_text_2,
}

@UseCase(name: 'Soft Hyphens', type: The_Art_of_the_Break)
Widget buildSoftHyphensUseCase(BuildContext context) {
  final textScaler = MediaQuery.textScalerOf(context);
  final softHyphens = context.knobs.object.dropdown(
    label: "Soft hyphens",
    options: _SoftHyphens.values,
    labelBuilder: (it) => it == _SoftHyphens.auto ? 'auto (German)' : it.name,
  );
  final package = context.knobs.object.dropdown(
    label: "Package",
    options: _Package.values,
    labelBuilder: (it) => it.name,
  );
  var title = context.knobs.string(
    label: 'Title',
    initialValue: 'Hinter(-)grund(-)aktualisierung ist deaktiviert',
    maxLines: 2,
  );
  final breakTitleNicely = context.knobs.boolean(label: 'Break title nicely');
  var text = context.knobs.string(
    label: 'Text',
    initialValue: 'Damit deine privaten Termine berück(-)sichtigt werden können, wenn Fahr(-)schüler Fahr(-)stunden buchen, müssen diese regel(-)mäßig an unsere Server übertragen werden. Hierfür muss die Hinter(-)grund(-)aktualisierung für die App ein(-)geschaltet sein.',
    maxLines: 10,
  );
  final textAlign = context.knobs.object.dropdown(
    label: "Text align",
    options: TextAlign.values,
    labelBuilder: (it) => it.name,
  );
  switch (softHyphens) {
    case _SoftHyphens.none:
      title = title.replaceAll('(-)', '');
      text = text.replaceAll('(-)', '');
    case _SoftHyphens.manual:
      title = title.replaceAll('(-)', '\u00AD');
      text = text.replaceAll('(-)', '\u00AD');
    case _SoftHyphens.auto:
      title = title.replaceAll('(-)', '').autoHyphenate();
      text = text.replaceAll('(-)', '').autoHyphenate();
  }

  Widget buildWidget(_Package strategy, String data_, TextStyle style, [TextAlign? textAlign]) {
    final data = data_.replaceAll('_', '\u00A0');
    return switch (strategy) {
      _Package.flutter => Text(data, style: style, textAlign: textAlign),
      _Package.auto_hyphenating_text => AutoHyphenatingText(data, style: style, textAlign: textAlign),
      _Package.custom_text_engine => Builder(
        builder: (_) {
          final textScaler = MediaQuery.textScalerOf(context);
          return AdvancedText(
            paragraphs: [
              ParagraphBlock(
                inlineElements: [
                  TextInlineElement(
                    text: data,
                    style: style.copyWith(fontSize: textScaler.scale(style.fontSize ?? 16)),
                  ),
                ],
              ),
            ],
            globalTextAlign: textAlign ?? TextAlign.start,
          );
        },
      ),
      _Package.flutter_hyphenation => HyphenText(data, locale: const Locale('de'), style: style, textAlign: textAlign),
      _Package.hyphenatorx => TextHyphenated(data, 'de_1996', style: style, textAlign: textAlign),
      _Package.soft_hyphen_text => SoftHyphenText(
        text: data,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        textScaleFactor: textScaler.scale(16) / 16,
      ),
      _Package.soft_hyphen_text_2 => SoftHyphenText2(data, style: style, textAlign: textAlign ?? TextAlign.start),
    };
  }

  return Column(
    children: [
      Expanded(child: SizedBox.shrink()),
      DartCode("Text('...') // no soft hyphens"),
      SizedBox(height: 8),
      WarningBox(
        buildTitle: (style) => Text(title.replaceAll('\u00AD', ''), style: style),
        buildText: (style) => Text(text.replaceAll('\u00AD', ''), style: style, textAlign: textAlign),
        button: AutovioButton('Öffne App-Einstellungen', customStyle: smallButtonStyle),
      ).withHorizontalPadding(20),
      Expanded(child: SizedBox.shrink()),
      switch (package) {
        _Package.flutter => DartCode("Text('...')"),
        _Package.auto_hyphenating_text => DartCode("AutoHyphenatingText(...)"),
        _Package.custom_text_engine => DartCode("AdvancedText(...)"),
        _Package.flutter_hyphenation => DartCode("HyphenText(...)"),
        _Package.hyphenatorx => DartCode("TextHyphenated(...)"),
        _Package.soft_hyphen_text => DartCode('SoftHyphenText(...)'),
        _Package.soft_hyphen_text_2 => DartCode('SoftHyphenText2(...)'),
      },
      SizedBox(height: 8),
      WarningBox(
        buildTitle: (style) => buildWidget(package, breakTitleNicely ? breakNicely(title) : title, style),
        buildText: (style) => buildWidget(package, text, style, textAlign),
        button: AutovioButton('Öffne App-Einstellungen', customStyle: smallButtonStyle),
      ).withHorizontalPadding(20),
      Expanded(child: SizedBox.shrink()),
    ],
  );
}
