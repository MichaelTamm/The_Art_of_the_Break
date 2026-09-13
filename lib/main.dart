import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hyphenation/flutter_hyphenation.dart';
import 'package:the_art_of_the_break_widgetbook/auto_hyphenate.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'addons/resizable_viewport_addon.dart';
import 'main.directories.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHyphenation();
  await initAutoHyphenate(const Locale('de'));
  await HyphenationRegistry.instance.registerAsset(const Locale('de'), 'assets/hyph-de-1996.tex');
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      lightTheme: ThemeData(scaffoldBackgroundColor: Colors.white),
      addons: [
        ResizableViewportAddon([
          Viewports.none,
          IosViewports.iPhoneSE,
          IosViewports.iPhone13,
          IosViewports.iPad,
          AndroidViewports.samsungGalaxyS20,
          AndroidViewports.samsungGalaxyNote20,
          LinuxViewports.desktop,
        ]),
        TextScaleAddon(),
        AlignmentAddon(),
      ],
      directories: directories,
    );
  }
}
