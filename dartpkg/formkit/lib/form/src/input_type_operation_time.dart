import 'package:flutter/material.dart' hide FormState;
import 'package:formkit/schema/schema.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:setup_widget/setup_widget.dart';

import 'form.dart';
import 'input_type.dart';

part '__generated__/input_type_operation_time.g.dart';

@JsonSerializable()
class OperationTime implements InputType {
  final String? type;

  const OperationTime({
    this.type,
  });

  @override
  build(ctx, entry, {viewMode}) {
    return _FormField(entry: entry, options: this);
  }

  @override
  validator(Entry entry) {
    return null;
  }

  factory OperationTime.fromJson(Map<String, dynamic> json) =>
      _$OperationTimeFromJson(json);
}

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final OperationTime options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    return () {
      return FormField(
        validator: (v) {
          switch (sc.widget.options.type) {
            case "ON_CREATED":
              formState.update(
                sc.widget.entry.name,
                // TODO fixed
                DateTime.now().toIso8601String(),
              );
            case "ON_COMMITTED":
              formState.update(
                sc.widget.entry.name,
                DateTime.now().toIso8601String(),
              );
          }
          return;
        },
        builder: (fieldState) {
          return SizedBox.shrink();
        },
      );
    };
  }
}
