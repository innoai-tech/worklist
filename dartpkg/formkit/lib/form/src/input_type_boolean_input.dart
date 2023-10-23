import 'package:formkit/schema/schema.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../validator/validator.dart';
import 'ext.dart';
import 'input_type.dart';
import 'input_type_selector.dart';

part '__generated__/input_type_boolean_input.g.dart';

@JsonSerializable()
class BooleanInput implements InputType {
  final bool? asCheckbox;

  const BooleanInput({
    this.asCheckbox,
  });

  @override
  build(ctx, entry, {viewMode}) {
    return Selector(options: [
      Option(label: "是", value: true),
      Option(label: "否", value: false),
    ]).build(ctx, entry, viewMode: viewMode);
  }

  validator(entry) {
    return compose([
      ...?entry.optional.ifFalse(() => [validateRequired()]),
    ]);
  }

  factory BooleanInput.fromJson(Map<String, dynamic> json) =>
      _$BooleanInputFromJson(json);
}
