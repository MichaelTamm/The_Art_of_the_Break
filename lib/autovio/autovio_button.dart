import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import 'autovio_styles.dart';
import 'autovio_textless.dart';
import 'layout_utils.dart';

void _nop() {}

class AutovioButton extends HookWidget {
  AutovioButton(
    String label, {
    super.key,
    this.icon,
    this.action = _nop,
    this.primary = true,
    this.disabled = false,
    this.disableSpinner = false,
    this.showSpinner = false,
    this.customStyle,
  }) : label = toBeginningOfSentenceCase(label),
       debugLabel = '';

  const AutovioButton.icon(
    this.icon, {
    super.key,
    required this.debugLabel,
    this.action = _nop,
    this.primary = false,
    this.disabled = false,
    bool enableSpinner = false,
    this.showSpinner = false,
    this.customStyle,
  }) : label = '',
       disableSpinner = !enableSpinner;

  final Widget? icon;
  final String label;
  final String debugLabel;
  final bool disabled;
  final bool primary;
  final bool disableSpinner;

  /// Set to `true` when` the action was triggered in a different way
  /// (e.g. by tapping OK on the virtual keyboard) to indicate to the
  /// user, that the action is being executed.
  final bool showSpinner;
  final FutureOr<void> Function()? action;
  final ButtonStyle? customStyle;

  @override
  Widget build(BuildContext context) {
    final disabled = this.disabled || action == null;
    final icon = this.icon;
    final labelWidget = breakNicely(label).text.alignCenter;
    var customStyle = this.customStyle;
    final isIconButton = icon != null && label.isEmpty;
    Widget child;

    if (icon == null) {
      child = labelWidget;
    } else {
      final isSmallButton = customStyle != null && isForSmallButton(customStyle);
      if (isSmallButton) {
        // Reduce padding for small buttons with an icon ...
        customStyle = customStyle.copyWith(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)));
      }
      child = isIconButton
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon, spacer(isSmallButton ? 5 : 10), labelWidget, spacer(5)],
            );
      // Always display an icon button as a perfect circle ...
      if (isIconButton) {
        final fixedSize = WidgetStatePropertyAll(Size.square(buttonSize));
        final padding = WidgetStatePropertyAll(EdgeInsets.zero);
        customStyle =
            customStyle?.copyWith(padding: padding, fixedSize: fixedSize) ??
            ButtonStyle(padding: padding, fixedSize: fixedSize);
      }
    }
    if (!disableSpinner) {
      // We use a `Stack` widget here, so that the button keeps its size when the spinner is displayed ...
      child = Stack(
        children: [
          child,
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedSwitcher(
                  // Delay appearance of AutovioButtonSpinner by 300 ms ...
                  duration: Duration(milliseconds: showSpinner ? 0 : 300),
                  switchInCurve: const Interval(0.6, 1, curve: Curves.linear),
                  switchOutCurve: const Interval(0.6, 1, curve: Curves.linear),
                  child: showSpinner
                      ? AutovioButtonSpinner(isPrimary: primary, customButtonStyle: customStyle)
                      : Container(),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return primary
        ? ElevatedButton(onPressed: showSpinner || disabled ? null : action, style: customStyle, child: child)
        : OutlinedButton(onPressed: showSpinner || disabled ? null : action, style: customStyle, child: child);
  }
}

class AutovioButtonSpinner extends StatelessWidget {
  const AutovioButtonSpinner({this.isPrimary = true, this.customButtonStyle, super.key});

  final bool isPrimary;
  final ButtonStyle? customButtonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = isPrimary ? theme.elevatedButtonTheme.style! : theme.outlinedButtonTheme.style!;
    final buttonLabelColor = customButtonStyle?.foregroundColor ?? defaultStyle.foregroundColor!;
    final buttonHeight =
        (customButtonStyle?.minimumSize ?? defaultStyle.minimumSize)?.resolve(const {})?.height ?? buttonSize;
    return SizedBox.square(
      dimension: buttonHeight - 20,
      child: CircularProgressIndicator(value: null, color: buttonLabelColor.resolve(const {})),
    );
  }
}

bool isForSmallButton(ButtonStyle style) {
  final minimumSize = style.minimumSize;
  if (minimumSize is WidgetStatePropertyAll<Size?>) {
    final value = minimumSize.value;
    if (value != null && value.height <= smallButtonSize) {
      return true;
    }
  }
  return false;
}
