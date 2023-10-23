import 'package:flutter/material.dart' as m;
import "package:formkit/schema/schema.dart";
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'ext.dart';
import 'input_type_ext.dart';

abstract class FormState {
  static final context = Context<FormState>.create(
    () => _FormState.seeded({}, key: m.GlobalKey<m.FormState>()),
  );

  bool validate();

  Map<String, dynamic> values();

  ValueStream<Map<String, dynamic>> get stream;

  void update(KeyPath name, dynamic value);
}

class _FormState implements FormState {
  factory _FormState.seeded(Map<String, dynamic> initialValues,
      {required m.GlobalKey<m.FormState> key}) {
    return _FormState(
      key: key,
      initialValues: initialValues,
      stream: BehaviorSubject.seeded(initialValues),
    );
  }

  m.GlobalKey<m.FormState> key;
  Map<String, dynamic> initialValues;
  BehaviorSubject<Map<String, dynamic>> stream;

  _FormState({
    required this.key,
    required this.stream,
    this.initialValues = const {},
  });

  bool validate() {
    return this.key.currentState?.validate() ?? false;
  }

  Map<String, dynamic> values() {
    return stream.value;
  }

  void update(KeyPath name, dynamic value) {
    final current = values();
    final patched = patch(current, name, value);
    if (patched != current) {
      stream.add(patched);
    }
  }
}

class Form extends SetupWidget<Form> {
  final Schema schema;
  final Map<String, dynamic> initialValues;
  final m.Widget Function(m.BuildContext ctx, FormState state, m.Widget fields)
      builder;

  final Function(Map<String, dynamic> values)? onChanged;

  const Form({
    required this.schema,
    required this.builder,
    this.initialValues = const {},
    this.onChanged,
  });

  @override
  setup(sc) {
    final formState = _FormState.seeded(
      sc.widget.initialValues,
      key: m.GlobalKey<m.FormState>(),
    );

    formState.stream.doOnData((values) {
      sc.widget.onChanged?.let((onChanged) {
        onChanged(values);
      });
    }).listenOnMountedUntilUnmounted();

    return () {
      final rootEntryContext = EntryContext(
        definitions: sc.widget.schema.definitions,
      );

      return m.Form(
        key: formState.key,
        child: FormState.context.provide(
          value: formState,
          child: formState.stream.buildOnData(
            (values) => sc.widget.builder(
              sc.context,
              formState,
              Entry(
                scope: rootEntryContext,
                type: schema,
                value: values,
              ).build(sc.context),
            ),
          ),
        ),
      );
    };
  }
}
