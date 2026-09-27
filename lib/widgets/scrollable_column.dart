import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A column that fills its viewport and scrolls when its contents need more room.
///
/// [Expanded] and [Spacer] children share spare height according to their flex
/// factors without shrinking below their natural heights. For example, an
/// `Expanded(child: SizedBox(height: 20))` retains at least 20 logical pixels.
///
/// Children are measured using actual layout, so [LayoutBuilder] is supported.
/// Flex children may be laid out twice: first to measure their natural heights,
/// then to apply their proportional share of the available height.
///
/// Requires bounded width and height, for example as a Scaffold body. Intended
/// for small, eagerly built layouts, not lazy lists. Children must support layout
/// with unbounded height; give nested scrollables or vertically expanding layouts
/// an explicit height, or make them shrink-wrap their contents.
class ScrollableColumn extends StatelessWidget {
  const ScrollableColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
    this.controller,
    this.physics,
  }) : assert(spacing >= 0),
       assert(crossAxisAlignment != CrossAxisAlignment.baseline);

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          throw FlutterError(
            'ScrollableColumn requires bounded width and height. '
            'Place it in a SizedBox, a Scaffold body, or an Expanded within '
            'a bounded layout.',
          );
        }
        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
            child: _Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              textDirection: Directionality.of(context),
              spacing: spacing,
              children: children,
            ),
          ),
        );
      },
    );
  }
}

class _Column extends MultiChildRenderObjectWidget {
  const _Column({
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.textDirection,
    required this.spacing,
    required super.children,
  });

  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection textDirection;
  final double spacing;

  @override
  _RenderColumn createRenderObject(BuildContext context) {
    return _RenderColumn(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderColumn renderObject) {
    renderObject
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection
      ..spacing = spacing;
  }
}

class _RenderColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  _RenderColumn({
    required this._mainAxisAlignment,
    required this._crossAxisAlignment,
    required this._textDirection,
    required this._spacing,
  });

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    final childConstraints = BoxConstraints(
      minWidth: crossAxisAlignment == CrossAxisAlignment.stretch ? constraints.maxWidth : 0,
      maxWidth: constraints.maxWidth,
    );
    final gapHeight = spacing * math.max(0, childCount - 1);
    var fixedHeight = gapHeight;
    var totalFlex = 0;
    var minimumHeightPerFlex = 0.0;
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as FlexParentData;
      child.layout(childConstraints, parentUsesSize: true);
      final flex = parentData.flex ?? 0;
      if (flex > 0) {
        totalFlex += flex;
        minimumHeightPerFlex = math.max(minimumHeightPerFlex, child.size.height / flex);
      } else {
        fixedHeight += child.size.height;
      }
      child = parentData.nextSibling;
    }

    // Preserve flex ratios while ensuring even the tallest flex child fits.
    final height = math.max(constraints.minHeight, fixedHeight + minimumHeightPerFlex * totalFlex);
    final heightPerFlex = totalFlex == 0 ? 0.0 : math.max(minimumHeightPerFlex, (height - fixedHeight) / totalFlex);
    var contentHeight = fixedHeight;
    child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as FlexParentData;
      final flex = parentData.flex ?? 0;
      if (flex > 0) {
        final allocatedHeight = heightPerFlex * flex;
        child.layout(
          childConstraints.copyWith(
            minHeight: parentData.fit == FlexFit.tight ? allocatedHeight : 0,
            maxHeight: allocatedHeight,
          ),
          parentUsesSize: true,
        );
        contentHeight += child.size.height;
      }
      child = parentData.nextSibling;
    }

    size = constraints.constrain(Size(constraints.maxWidth, height));
    final freeHeight = math.max(0.0, size.height - contentHeight);
    final (leadingSpace, betweenSpace) = switch (mainAxisAlignment) {
      MainAxisAlignment.start => (0.0, spacing),
      MainAxisAlignment.end => (freeHeight, spacing),
      MainAxisAlignment.center => (freeHeight / 2, spacing),
      MainAxisAlignment.spaceBetween => (0.0, spacing + (childCount > 1 ? freeHeight / (childCount - 1) : 0.0)),
      MainAxisAlignment.spaceAround => (
        childCount > 0 ? freeHeight / childCount / 2 : 0.0,
        spacing + (childCount > 0 ? freeHeight / childCount : 0.0),
      ),
      MainAxisAlignment.spaceEvenly => (freeHeight / (childCount + 1), spacing + freeHeight / (childCount + 1)),
    };

    var y = leadingSpace;
    child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as FlexParentData;
      final freeWidth = size.width - child.size.width;
      final x = switch (crossAxisAlignment) {
        CrossAxisAlignment.start => textDirection == TextDirection.ltr ? 0.0 : freeWidth,
        CrossAxisAlignment.end => textDirection == TextDirection.ltr ? freeWidth : 0.0,
        CrossAxisAlignment.center => freeWidth / 2,
        CrossAxisAlignment.stretch || CrossAxisAlignment.baseline => 0.0,
      };
      parentData.offset = Offset(x, y);
      y += child.size.height + betweenSpace;
      child = parentData.nextSibling;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
