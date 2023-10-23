import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:formkit/schema/schema.dart';

import 'ext.dart';
import 'input_type.dart';
import 'input_type_boolean_input.dart';
import 'input_type_datetime_picker.dart';
import 'input_type_file_selector.dart';
import 'input_type_form_array.dart';
import 'input_type_form_group.dart';
import 'input_type_number_input.dart';
import 'input_type_operation_time.dart';
import 'input_type_selector.dart';
import 'input_type_text_input.dart';

extension SchemaExtInputType on Schema {
  Schema inputBy(InputType inputType) {
    return copyWithMetadata({
      "inputBy": inputType,
    });
  }
}

extension EntryExtInputType on Entry {
  InputType get inputBy {
    final inputBy = this.type.metadata["inputBy"];

    if (inputBy is InputType) {
      return inputBy;
    }

    if (inputBy is Map<String, dynamic>) {
      final kind = inputBy["kind"];

      switch (kind) {
        case "operation-time":
          return OperationTime.fromJson(inputBy);
        case "text-input":
          return TextInput.fromJson(inputBy);
        case "number-input":
          return NumberInput.fromJson(inputBy);
        case "datetime-input":
          return DatetimePicker.fromJson(inputBy);
        case "file-selector":
          return FileSelector.fromJson(inputBy);
        default:
          throw Exception("unsupported $kind");
      }
    }

    if (inputBy == null) {
      if (this.type is TaggedUnionType) {
        return FormGroup();
      }

      if (this.type is ObjectType) {
        return FormGroup();
      }

      if (this.type is ArrayType) {
        return FormArray();
      }

      if (this.type is EnumType) {
        return Selector(
          options: (this.type as EnumType).let((e) {
            final enumLabels = e.metadata["enumLabels"] ?? e.values;

            return e.values
                .mapIndexed((i, value) =>
                    Option(label: enumLabels[i].toString(), value: value))
                .toList();
          }),
        );
      }

      if (this.type is PrimitiveType) {
        switch ((this.type as PrimitiveType).type) {
          case "timestamp":
            return DatetimePicker();
          case "string":
            return TextInput();
          case "boolean":
            return BooleanInput();
          default:
            return NumberInput();
        }
      }
    }

    throw Exception("unsupported inputType $inputBy for ${this.type}");
  }

  Widget build(
    BuildContext buildContext, {
    bool? viewMode,
  }) {
    return inputBy.build(
      buildContext,
      this,
      viewMode: viewMode,
    );
  }
}
