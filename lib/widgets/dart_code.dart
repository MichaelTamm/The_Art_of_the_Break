import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

Highlighter? dartSyntaxHighlighter;

Future<void> _init() async {
  try {
    await Highlighter.initialize(['dart']);
    final theme = await HighlighterTheme.loadLightTheme();
    dartSyntaxHighlighter = Highlighter(language: 'dart', theme: theme);
  } catch (error, stack) {
    debugPrintStack(label: '$error', stackTrace: stack);
  }
}

Future<void>? __initFuture;

Future<void> get _initFuture => __initFuture ??= _init();

class DartCode extends HookWidget {
  const DartCode(this.dartCode, {super.key});

  final String dartCode;

  @override
  Widget build(BuildContext context) {
    useFuture(_initFuture);

    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 20, fontFamily: 'JetBrainsMono'),
      child: Text.rich(
        dartSyntaxHighlighter?.highlight(dartCode) ?? TextSpan(text: '...'),
      ),
    );
  }
}
