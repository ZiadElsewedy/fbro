import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/widgets/segmented_tab_bar.dart';

void main() {
  Widget host({
    required TabController controller,
    required List<String> tabs,
  }) =>
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            bottom: SegmentedTabBar(controller: controller, tabs: tabs),
          ),
          body: TabBarView(
            controller: controller,
            children: [for (final t in tabs) Center(child: Text('$t page'))],
          ),
        ),
      );

  testWidgets('renders every segment label', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      host(controller: controller, tabs: const ['Active', 'Done']),
    );

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('reports a 44px preferred height for the app bar slot', (
    tester,
  ) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);
    final bar = SegmentedTabBar(controller: controller, tabs: const ['A', 'B']);
    expect(bar.preferredSize.height, 44);
  });

  testWidgets('tapping a segment drives the paired TabBarView', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      host(controller: controller, tabs: const ['Active', 'Done']),
    );
    expect(controller.index, 0);
    expect(find.text('Active page'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(controller.index, 1);
    expect(find.text('Done page'), findsOneWidget);
  });
}
