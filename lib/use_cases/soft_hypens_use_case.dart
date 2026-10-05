// ignore_for_file: constant_identifier_names

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:custom_text_engine/custom_text_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hyphenation/flutter_hyphenation.dart';
import 'package:hyphenatorx/widget/texthyphenated.dart';
import 'package:soft_hyphen_text/soft_hyphen_text.dart';
import 'package:soft_hyphen_text_2/soft_hyphen_text_2.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../auto_hyphenate.dart';
import '../autovio/autovio_button.dart';
import '../autovio/autovio_styles.dart';
import '../autovio/layout_utils.dart';
import '../autovio/warning_box.dart';
import '../the_art_of_the_break.dart';
import '../widgets/dart_code.dart';
import '../widgets/scrollable_column.dart';

enum _SoftHyphens { none, manual, auto }

enum _Package {
  flutter,
  auto_hyphenating_text,
  custom_text_engine,
  flutter_hyphenation,
  hyphenatorx,
  soft_hyphen_text,
  soft_hyphen_text_2__first_fit,
  soft_hyphen_text_2__knuth_plass,
}

@UseCase(name: 'Soft Hyphens', type: The_Art_of_the_Break)
Widget buildSoftHyphensUseCase(BuildContext context) {
  final textScaler = MediaQuery.textScalerOf(context);
  final textAlign = context.knobs.object.dropdown(
    label: "Text align",
    options: TextAlign.values,
    labelBuilder: (it) => it.name,
  );
  final softHyphens = context.knobs.object.dropdown(
    label: "Soft hyphens",
    options: _SoftHyphens.values,
    labelBuilder: (it) => it == _SoftHyphens.auto ? 'auto (German)' : it.name,
    initialOption: _SoftHyphens.none
  );
  final packageCard1 = context.knobs.object.dropdown(
    label: "Package for card 1",
    options: _Package.values,
    labelBuilder: (it) => switch (it) {
      _Package.soft_hyphen_text_2__first_fit => 'soft_hyphen_text_2 (First Fit)',
      _Package.soft_hyphen_text_2__knuth_plass => 'soft_hyphen_text_2 (Knuth-Plass)',
      _ => it.name,
    },
  );
  final packageCard2 = context.knobs.object.dropdown(
    label: "Package for card 2",
    options: _Package.values,
    labelBuilder: (it) => switch (it) {
      _Package.soft_hyphen_text_2__first_fit => 'soft_hyphen_text_2 (First Fit)',
      _Package.soft_hyphen_text_2__knuth_plass => 'soft_hyphen_text_2 (Knuth-Plass)',
      _ => it.name,
    },
    initialOption: _Package.soft_hyphen_text_2__first_fit,
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

  Widget buildTextWidget(_Package package, String data_, TextStyle style, [TextAlign? textAlign]) {
    final data = data_.replaceAll('_', '\u00A0');
    return switch (package) {
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
      _Package.soft_hyphen_text_2__first_fit => SoftHyphenText2(
        data,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        layoutAlgorithm: LayoutAlgorithm.firstFit,
      ),
      _Package.soft_hyphen_text_2__knuth_plass => SoftHyphenText2(
        data,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
      ),
    };
  }

  Iterable<Widget> buildWidgets(_Package package) sync* {
    yield switch (package) {
      _Package.flutter => DartCode("Text('...')"),
      _Package.auto_hyphenating_text => DartCode("AutoHyphenatingText(...)"),
      _Package.custom_text_engine => DartCode("AdvancedText(...)"),
      _Package.flutter_hyphenation => DartCode("HyphenText(...)"),
      _Package.hyphenatorx => DartCode("TextHyphenated(...)"),
      _Package.soft_hyphen_text => DartCode('SoftHyphenText(...)'),
      _Package.soft_hyphen_text_2__first_fit => DartCode('SoftHyphenText2(...)'),
      _Package.soft_hyphen_text_2__knuth_plass => DartCode('SoftHyphenText2(...)'),
    };
    yield SizedBox(height: 8);
    yield WarningBox(
      buildTitle: (style) => buildTextWidget(package, breakTitleNicely ? breakNicely2(title) : title, style),
      buildText: (style) => buildTextWidget(package, text, style, textAlign),
      button: AutovioButton('Öffne App-Einstellungen', customStyle: smallButtonStyle),
    ).withHorizontalPadding(20);
  }

  return ScrollableColumn(
    children: [
      Expanded(child: SizedBox(height: 8)),
      ...buildWidgets(packageCard1),
      Expanded(child: SizedBox(height: 24)),
      ...buildWidgets(packageCard2),
      Expanded(child: SizedBox(height: 8)),
    ],
  );
}
