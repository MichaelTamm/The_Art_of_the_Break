import 'package:flutter/material.dart';

class SplitScreen extends StatelessWidget {
  const SplitScreen({
    super.key,
    required this.children,
    required this.childSize,
    this.childAlignment = Alignment.center,
  });

  final List<Widget> children;
  final Size childSize;
  final Alignment childAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map(
            (child) => Expanded(
              child: Align(
                alignment: childAlignment,
                child: _buildChildContainer(child),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChildContainer(Widget child) {
    return SizedBox(
      width: childSize.width,
      height: childSize.height,
      child: child,
    );
  }
}
