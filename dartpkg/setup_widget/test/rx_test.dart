import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_widget/setup_widget.dart';

void main() {
  testWidgets('render from props', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Container(initial: 1),
    ));

    expect(find.text('value_from_rx__1'), findsOneWidget);
    expect(find.text('value_from_prop__1'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('value_from_rx__2'), findsOneWidget);
    expect(find.text('value_from_prop__2'), findsOneWidget);
  });
}

class Container extends SetupWidget<Container> {
  final int initial;

  const Container({
    required this.initial,
    super.key,
  });

  @override
  setup(s) {
    final countRef = observableRef(initial);

    final countEl = countRef.stream.buildOnData((count) {
      return Column(
        children: [
          Text("value_from_rx__$count"),
          CustomText(text: "$count"),
        ],
      );
    });

    return () {
      return Center(
        child: Column(
          children: [
            countEl,
            FilledButton(
              onPressed: () {
                countRef.value++;
              },
              child: const Text("Count"),
            )
          ],
        ),
      );
    };
  }
}

class CustomText extends SetupWidget<CustomText> {
  final String text;

  const CustomText({
    required this.text,
    super.key,
  });

  @override
  setup(s) {
    final text$ = toObservable(() => s.widget.text);

    final textEl = text$.buildOnData((text) {
      return Text("value_from_prop__$text");
    });

    return () {
      return textEl;
    };
  }
}
