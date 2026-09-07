// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:the_art_of_the_break_widgetbook/use_cases/lonely_symbol_eur_use_case.dart'
    as _the_art_of_the_break_widgetbook_use_cases_lonely_symbol_eur_use_case;
import 'package:the_art_of_the_break_widgetbook/use_cases/lonely_symbol_kmh_use_case.dart'
    as _the_art_of_the_break_widgetbook_use_cases_lonely_symbol_kmh_use_case;
import 'package:the_art_of_the_break_widgetbook/use_cases/text_overflow_use_case.dart'
    as _the_art_of_the_break_widgetbook_use_cases_text_overflow_use_case;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookComponent(
    name: 'The_Art_of_the_Break',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Lonely Symbol km/h',
        builder:
            _the_art_of_the_break_widgetbook_use_cases_lonely_symbol_kmh_use_case
                .buildLonelySymbolKmhUseCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Lonely Symbol €',
        builder:
            _the_art_of_the_break_widgetbook_use_cases_lonely_symbol_eur_use_case
                .buildLonelySymbolEurUseCase,
      ),
      _widgetbook.WidgetbookUseCase(
        name: 'Text Overflow',
        builder:
            _the_art_of_the_break_widgetbook_use_cases_text_overflow_use_case
                .buildTextOverflowUseCase,
      ),
    ],
  ),
];
