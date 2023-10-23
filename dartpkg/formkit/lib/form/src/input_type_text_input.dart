import 'package:flutter/material.dart' hide FormState;
import 'package:formkit/schema/schema.dart';
import 'package:formkit/validator/validator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'common.dart';
import 'ext.dart';
import 'form.dart';
import 'input_type.dart';

part '__generated__/input_type_text_input.g.dart';

@JsonSerializable()
class TextInput implements InputType {
  final String? pattern;
  final String? format;
  final int? minChars;
  final int? maxChars;
  final String? mask;

  const TextInput({
    this.mask,
    this.pattern,
    this.format,
    this.minChars,
    this.maxChars,
  });

  @override
  build(ctx, entry, {viewMode}) {
    if (viewMode ?? false) {
      return InputView(
        label: Text("${entry.label ?? entry.key}"),
        validator: validator(entry),
        value: entry.value,
        builder: (value) {
          return Text("${value ?? ""}");
        },
      );
    }
    return _FormField(entry: entry, options: this);
  }

  validator(entry) {
    return compose([
      ...?entry.optional.ifFalse(() => [validateRequired()]),
      ...?format
          ?.let((format) => resolveFormatValidator(format))
          ?.let((fn) => [fn()]),
    ]);
  }

  factory TextInput.fromJson(Map<String, dynamic> json) =>
      _$TextInputFromJson(json);
}

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final TextInput options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final controller = TextEditingController(
      text: sc.widget.entry.value,
    );

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      controller.text = newValue ?? "";
    }).listenOnMountedUntilUnmounted();

    final clearValue = () {
      controller.clear();
      formState.update(sc.widget.entry.name, null);
    };

    return () {
      return TextFormField(
        controller: controller,
        onChanged: (value) {
          formState.update(sc.widget.entry.name, value);
        },
        decoration: sc.widget.entry.inputDecoration(
          sc.context,
          suffixIcon: sc.widget.entry.hasValue.ifTrue(
                () => IconButton(
                  onPressed: clearValue,
                  icon: Icon(Icons.clear),
                ),
              ) ??
              sc.widget.entry.descriptionWidget(sc.context),
        ),
        validator: sc.widget.options.validator(sc.widget.entry),
      );
    };
  }
}

FormFieldValidator<T> Function({String? msg})? resolveFormatValidator<T>(
    String format) {
  switch (format) {
    case "url":
      return validateFormatURL;
  }
  return null;
}
