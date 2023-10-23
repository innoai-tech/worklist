import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_widget/setup_widget.dart';

void main() {
  testWidgets('render from props', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Container(initial: 1),
    ));

    expect(find.text('value_from_prop__1'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('value_from_prop__2'), findsOneWidget);
  });

  testWidgets('render from ref, with updates from props', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Container(initial: 1),
    ));

    expect(find.text('value_from_ref__1'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.text('value_from_ref__1_suffix'), findsOneWidget);

    for (var i = 1; i <= 5; i++) {
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('value_from_ref__${1 + i}'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('value_from_ref__${1 + i}_suffix'), findsOneWidget);
    }
  });

  group("Context", () {
    testWidgets("should use default value", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ContextValueUse(),
      ));

      expect(find.text('text_from_context_default'), findsOneWidget);
    });

    testWidgets("should use overwrites value", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValueContext.Provider(
          value: "text_from_context_injected",
          child: const ContextValueUse(),
        ),
      ));

      expect(find.text('text_from_context_injected'), findsOneWidget);
    });
  });
}

final ValueContext = Context.create(() => "text_from_context_default");

class ContextValueUse extends SetupWidget {
  const ContextValueUse({
    super.key,
  });

  @override
  get setup =>
      createSetup<Container>((s) {
        final s = ValueContext.use();

        return () {
          return Center(
            child: Text(s),
          );
        };
      });
}

class Container extends SetupWidget {
  final int initial;

  const Container({
    required this.initial,
    super.key,
  });

  @override
  get setup =>
      createSetup<Container>((s) {
        final count = ref(initial);

        return () {
          return Center(
            child: Column(
              children: [
                UncontrolledCustomText(text: "${count.value}"),
                ControlledCustomText(text: "${count.value}"),
                FilledButton(
                  onPressed: () {
                    count.value++;
                  },
                  child: Text("Count"),
                )
              ],
            ),
          );
        };
      });
}

class UncontrolledCustomText extends SetupWidget {
  final String text;

  const UncontrolledCustomText({
    required this.text,
    super.key,
  });

  @override
  get setup =>
      createSetup<UncontrolledCustomText>((s) {
        return () {
          return Text("value_from_prop__${s.widget.text}");
        };
      });
}

class ControlledCustomText extends SetupWidget {
  final String text;

  const ControlledCustomText({
    required this.text,
    super.key,
  });

  @override
  get setup =>
      createSetup<ControlledCustomText>((s) {
        final text = ref(s.widget.text);

        watch(() => s.widget.text, (value, prev) {
          text.value = value;
        });

        return () {
          return TextButton(
            onPressed: () {
              text.value += "_suffix";
            },
            child: Text("value_from_ref__${text.value}"),
          );
        };
      });
}
