import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// A [WidgetbookAddon] that displays a resizable viewport.
///
/// The available [viewports] can be selected from the addon's dropdown to
/// apply a predefined viewport size. The displayed viewport can then be
/// resized by dragging any of its borders or corners.
class ResizableViewportAddon extends WidgetbookAddon<ViewportData> {
  /// Creates a resizable viewport addon with the available [viewports].
  ResizableViewportAddon(List<ViewportData> viewports)
    : assert(viewports.isNotEmpty, 'At least one viewport is required.'),
      viewports = List.unmodifiable(viewports),
      super(name: 'Resizable Viewport');

  /// The predefined viewport sizes available in the addon panel.
  final List<ViewportData> viewports;

  final _resetSignal = ValueNotifier(0);

  late final List<Field> _fields = [
    _ViewportPresetField(
      name: 'name',
      initialValue: viewports.first,
      values: viewports,
      onViewportSelected: () => _resetSignal.value++,
    ),
  ];

  @override
  List<Field> get fields => _fields;

  @override
  ViewportData valueFromQueryGroup(Map<String, String> group) {
    return valueOf<ViewportData>('name', group)!;
  }

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    ViewportData setting,
  ) {
    // This has the same behaviour as Widgetbook's ViewportAddon for the
    // built-in `Viewports.none` value, without relying on its internal type.
    if (setting.width == 0 && setting.height == 0) return child;

    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: _resetSignal,
        child: child,
        builder: (context, resetVersion, child) {
          return _ResizableViewport(
            data: setting,
            viewports: viewports,
            frameless: WidgetbookState.maybeOf(context)?.previewMode ?? false,
            resetVersion: resetVersion,
            child: child!,
          );
        },
      ),
    );
  }
}

class _ViewportPresetField extends ObjectDropdownField<ViewportData> {
  _ViewportPresetField({
    required super.name,
    required super.values,
    required super.initialValue,
    required this.onViewportSelected,
  }) : super(labelBuilder: (viewport) => viewport.name);

  final VoidCallback onViewportSelected;

  @override
  Widget toWidget(BuildContext context, String group, ViewportData? value) {
    return DropdownMenu<ViewportData>(
      expandedInsets: EdgeInsets.zero,
      trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded),
      initialSelection: value,
      onSelected: (viewport) {
        if (viewport == null) return;

        updateField(context, group, viewport);
        onViewportSelected();
      },
      dropdownMenuEntries: values
          .map(
            (viewport) => DropdownMenuEntry(
              value: viewport,
              label: labelBuilder(viewport),
            ),
          )
          .toList(),
    );
  }
}

class _ResizableViewport extends StatefulWidget {
  const _ResizableViewport({
    required this.data,
    required this.viewports,
    required this.frameless,
    required this.resetVersion,
    required this.child,
  });

  final ViewportData data;
  final List<ViewportData> viewports;
  final bool frameless;
  final int resetVersion;
  final Widget child;

  @override
  State<_ResizableViewport> createState() => _ResizableViewportState();
}

class _ResizableViewportState extends State<_ResizableViewport> {
  static const _minimumExtent = 1.0;

  late Size _size;
  var _translation = Offset.zero;

  @override
  void initState() {
    super.initState();
    _size = widget.data.size;
  }

  @override
  void didUpdateWidget(covariant _ResizableViewport oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data ||
        oldWidget.resetVersion != widget.resetVersion) {
      _size = widget.data.size;
      _translation = Offset.zero;
    }
  }

  void _resize(_ResizeDirection direction, Offset delta) {
    final oldSize = _size;
    final newWidth = switch (direction) {
      _ResizeDirection.left ||
      _ResizeDirection.topLeft ||
      _ResizeDirection.bottomLeft => (oldSize.width - delta.dx).clamp(
        _minimumExtent,
        double.infinity,
      ),
      _ResizeDirection.right ||
      _ResizeDirection.topRight ||
      _ResizeDirection.bottomRight => (oldSize.width + delta.dx).clamp(
        _minimumExtent,
        double.infinity,
      ),
      _ => oldSize.width,
    };
    final newHeight = switch (direction) {
      _ResizeDirection.top ||
      _ResizeDirection.topLeft ||
      _ResizeDirection.topRight => (oldSize.height - delta.dy).clamp(
        _minimumExtent,
        double.infinity,
      ),
      _ResizeDirection.bottom ||
      _ResizeDirection.bottomLeft ||
      _ResizeDirection.bottomRight => (oldSize.height + delta.dy).clamp(
        _minimumExtent,
        double.infinity,
      ),
      _ => oldSize.height,
    };
    final newSize = Size(newWidth, newHeight);

    if (newSize == oldSize) return;

    final widthChange = newSize.width - oldSize.width;
    final heightChange = newSize.height - oldSize.height;
    final translation =
        _translation +
        Offset(
          switch (direction) {
            _ResizeDirection.left ||
            _ResizeDirection.topLeft ||
            _ResizeDirection.bottomLeft => -widthChange / 2,
            _ResizeDirection.right ||
            _ResizeDirection.topRight ||
            _ResizeDirection.bottomRight => widthChange / 2,
            _ => 0,
          },
          switch (direction) {
            _ResizeDirection.top ||
            _ResizeDirection.topLeft ||
            _ResizeDirection.topRight => -heightChange / 2,
            _ResizeDirection.bottom ||
            _ResizeDirection.bottomLeft ||
            _ResizeDirection.bottomRight => heightChange / 2,
            _ => 0,
          },
        );

    setState(() {
      _size = newSize;
      _translation = translation;
    });
  }

  ViewportData? get _matchingViewport {
    if (widget.data.width == _size.width &&
        widget.data.height == _size.height) {
      return widget.data;
    }

    for (final viewport in widget.viewports) {
      if (viewport.width == _size.width && viewport.height == _size.height) {
        return viewport;
      }
    }

    return null;
  }

  String get _title {
    final dimensions =
        '${_formatDimension(_size.width)}x'
        '${_formatDimension(_size.height)}';
    final viewport = _matchingViewport;

    return viewport == null ? dimensions : '$dimensions (${viewport.name})';
  }

  @override
  Widget build(BuildContext context) {
    final viewportData = ViewportData(
      name: _title,
      width: _size.width,
      height: _size.height,
      pixelRatio: widget.data.pixelRatio,
      platform: widget.data.platform,
      safeAreas: widget.data.safeAreas,
    );
    final mediaQuery = MediaQuery.of(context).copyWith(
      size: viewportData.size,
      devicePixelRatio: viewportData.pixelRatio,
      padding: viewportData.safeAreas,
      viewPadding: viewportData.safeAreas,
    );
    final theme = Theme.of(context).copyWith(platform: viewportData.platform);

    return FittedBox(
      child: Transform.translate(
        offset: _translation,
        child: _ViewportFrame(
          title: _title,
          frameless: widget.frameless,
          size: _size,
          onResize: _resize,
          child: SizedBox(
            width: _size.width,
            height: _size.height,
            child: Theme(
              data: theme,
              child: MediaQuery(
                data: mediaQuery,
                child: Navigator(
                  onGenerateRoute: (_) => PageRouteBuilder(
                    pageBuilder: (context, _, _) => widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewportFrame extends StatelessWidget {
  const _ViewportFrame({
    required this.title,
    required this.frameless,
    required this.size,
    required this.onResize,
    required this.child,
  });

  static const _borderWidth = 2.0;

  final String title;
  final bool frameless;
  final Size size;
  final void Function(_ResizeDirection direction, Offset delta) onResize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewport = _ResizableViewportSurface(
      size: size,
      onResize: onResize,
      child: child,
    );

    if (frameless) return viewport;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(-_borderWidth, 0),
            child: Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
              ),
            ),
          ),
          viewport,
        ],
      ),
    );
  }
}

class _ResizableViewportSurface extends StatelessWidget {
  const _ResizableViewportSurface({
    required this.size,
    required this.onResize,
    required this.child,
  });

  static const _handleExtent = 12.0;

  final Size size;
  final void Function(_ResizeDirection direction, Offset delta) onResize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: _ViewportFrame._borderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: child,
          ),
          _edgeHandle(
            key: const ValueKey('resizable-viewport-top-handle'),
            direction: _ResizeDirection.top,
            top: 0,
            left: _handleExtent,
            right: _handleExtent,
            height: _handleExtent,
          ),
          _edgeHandle(
            key: const ValueKey('resizable-viewport-bottom-handle'),
            direction: _ResizeDirection.bottom,
            bottom: 0,
            left: _handleExtent,
            right: _handleExtent,
            height: _handleExtent,
          ),
          _edgeHandle(
            key: const ValueKey('resizable-viewport-left-handle'),
            direction: _ResizeDirection.left,
            top: _handleExtent,
            bottom: _handleExtent,
            left: 0,
            width: _handleExtent,
          ),
          _edgeHandle(
            key: const ValueKey('resizable-viewport-right-handle'),
            direction: _ResizeDirection.right,
            top: _handleExtent,
            bottom: _handleExtent,
            right: 0,
            width: _handleExtent,
          ),
          _cornerHandle(
            key: const ValueKey('resizable-viewport-top-left-handle'),
            direction: _ResizeDirection.topLeft,
            top: 0,
            left: 0,
          ),
          _cornerHandle(
            key: const ValueKey('resizable-viewport-top-right-handle'),
            direction: _ResizeDirection.topRight,
            top: 0,
            right: 0,
          ),
          _cornerHandle(
            key: const ValueKey('resizable-viewport-bottom-left-handle'),
            direction: _ResizeDirection.bottomLeft,
            bottom: 0,
            left: 0,
          ),
          _cornerHandle(
            key: const ValueKey('resizable-viewport-bottom-right-handle'),
            direction: _ResizeDirection.bottomRight,
            bottom: 0,
            right: 0,
          ),
        ],
      ),
    );
  }

  Widget _edgeHandle({
    required Key key,
    required _ResizeDirection direction,
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      width: width,
      height: height,
      child: _ResizeHandle(key: key, direction: direction, onResize: onResize),
    );
  }

  Widget _cornerHandle({
    required Key key,
    required _ResizeDirection direction,
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) {
    return _edgeHandle(
      key: key,
      direction: direction,
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      width: _handleExtent,
      height: _handleExtent,
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    super.key,
    required this.direction,
    required this.onResize,
  });

  final _ResizeDirection direction;
  final void Function(_ResizeDirection direction, Offset delta) onResize;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: direction.cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onResize(direction, details.delta),
      ),
    );
  }
}

enum _ResizeDirection {
  top(SystemMouseCursors.resizeUpDown),
  right(SystemMouseCursors.resizeLeftRight),
  bottom(SystemMouseCursors.resizeUpDown),
  left(SystemMouseCursors.resizeLeftRight),
  topLeft(SystemMouseCursors.resizeUpLeftDownRight),
  topRight(SystemMouseCursors.resizeUpRightDownLeft),
  bottomRight(SystemMouseCursors.resizeUpLeftDownRight),
  bottomLeft(SystemMouseCursors.resizeUpRightDownLeft);

  const _ResizeDirection(this.cursor);

  final MouseCursor cursor;
}

String _formatDimension(double value) {
  return value.round().toString();
}
