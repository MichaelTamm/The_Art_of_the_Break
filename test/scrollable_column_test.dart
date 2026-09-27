import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_art_of_the_break_widgetbook/widgets/scrollable_column.dart';

void main() {
  testWidgets('expanded children share spare height according to flex', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        height: 500,
        child: ScrollableColumn(
          controller: controller,
          children: const [
            SizedBox(height: 50),
            Expanded(child: SizedBox(key: Key('first'), height: 20)),
            Expanded(flex: 3, child: SizedBox(key: Key('second'), height: 30)),
            SizedBox(height: 50),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('first'))).height, 100);
    expect(tester.getSize(find.byKey(const Key('second'))).height, 300);
    expect(tester.getSize(find.byType(ScrollableColumn)).height, 500);
    expect(controller.position.maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short viewports scroll without shrinking expanded content', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        height: 150,
        child: ScrollableColumn(
          controller: controller,
          children: const [
            SizedBox(height: 100),
            Expanded(child: SizedBox(key: Key('gap'), height: 20)),
            SizedBox(key: Key('footer'), height: 100),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('gap'))).height, 20);
    expect(tester.getBottomLeft(find.byKey(const Key('footer'))).dy, 220);
    expect(controller.position.maxScrollExtent, 70);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ScrollableColumn), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(controller.offset, 70);
    expect(tester.getBottomLeft(find.byKey(const Key('footer'))).dy, 150);
  });

  testWidgets('resizing switches between expanding and scrolling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final column = ScrollableColumn(
      controller: controller,
      children: const [
        SizedBox(height: 100),
        Expanded(child: SizedBox(key: Key('gap'), height: 20)),
        SizedBox(height: 100),
      ],
    );

    await tester.pumpWidget(_app(height: 400, child: column));
    expect(tester.getSize(find.byKey(const Key('gap'))).height, 200);
    expect(controller.position.maxScrollExtent, 0);

    await tester.pumpWidget(_app(height: 150, child: column));
    expect(tester.getSize(find.byKey(const Key('gap'))).height, 20);
    expect(controller.position.maxScrollExtent, 70);
    controller.jumpTo(70);

    await tester.pumpWidget(_app(height: 400, child: column));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('gap'))).height, 200);
    expect(controller.position.maxScrollExtent, 0);
    expect(controller.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrapped expanded text determines scrollable height', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final text = List.filled(40, 'wrapped text').join(' ');

    await tester.pumpWidget(
      _app(
        width: 120,
        height: 150,
        child: ScrollableColumn(
          controller: controller,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );

    final textSize = tester.getSize(find.text(text));
    expect(textSize.width, 120);
    expect(textSize.height, greaterThan(90));
    expect(controller.position.maxScrollExtent, closeTo(textSize.height + 60 - 150, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-flex content honors alignment and spacing', (tester) async {
    await tester.pumpWidget(
      _app(
        height: 300,
        child: const ScrollableColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 20,
          children: [
            SizedBox(key: Key('first'), width: 40, height: 40),
            SizedBox(key: Key('second'), width: 40, height: 40),
          ],
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(const Key('first'))), const Offset(260, 100));
    expect(tester.getTopLeft(find.byKey(const Key('second'))), const Offset(260, 160));
    expect(tester.takeException(), isNull);
  });

  testWidgets('spacers collapse when fixed content exceeds the viewport', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final column = ScrollableColumn(
      controller: controller,
      spacing: 10,
      children: const [
        SizedBox(height: 100),
        Spacer(),
        SizedBox(key: Key('footer'), height: 100),
      ],
    );

    await tester.pumpWidget(_app(height: 400, child: column));
    expect(tester.getTopLeft(find.byKey(const Key('footer'))).dy, 300);
    expect(controller.position.maxScrollExtent, 0);

    await tester.pumpWidget(_app(height: 150, child: column));
    expect(tester.getTopLeft(find.byKey(const Key('footer'))).dy, 120);
    expect(controller.position.maxScrollExtent, 70);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty column fills the viewport without scrolling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        height: 300,
        child: ScrollableColumn(controller: controller, children: const []),
      ),
    );

    expect(tester.getSize(find.byType(ScrollableColumn)).height, 300);
    expect(controller.position.maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({double width = 300, required double height, required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: .topLeft,
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}
