import 'package:flutter/material.dart' hide FormState;
import 'package:flutter/services.dart';
import 'package:formkit/schema/schema.dart';
import 'package:formkit/validator/validator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'common.dart';
import 'ext.dart';
import 'form.dart';
import 'input_type.dart';

part '__generated__/input_type_number_input.g.dart';

@JsonSerializable()
class NumberInput implements InputType {
  final double? min;
  final double? max;

  const NumberInput({
    this.min,
    this.max,
  });

  @override
  build(ctx, entry, {viewMode}) {
    if (viewMode ?? false) {
      return InputView(
        label: Text("${entry.label ?? entry.key}"),
        validator: validator(entry),
        value: entry.value,
        builder: (value) {
          if (value != null) {
            return Text("${value}");
          }
          return Text("");
        },
      );
    }
    return _FormField(entry: entry, options: this);
  }

  factory NumberInput.fromJson(Map<String, dynamic> json) =>
      _$NumberInputFromJson(json);

  @override
  validator(entry) {
    return compose([
      ...?entry.optional.ifFalse(() => [validateRequired()]),
    ]);
  }
}

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final NumberInput options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final controller = TextEditingController(
      text: "${sc.widget.entry.value ?? ""}",
    );

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      controller.text = "${newValue ?? ""}";
    }).listenOnMountedUntilUnmounted();

    final clearValue = () {
      controller.clear();
      formState.update(sc.widget.entry.name, null);
    };

    final safeParseNumber = (String s) {
      try {
        return num.parse(s);
      } catch (e) {}
      return null;
    };

    return () {
      final schema = sc.widget.entry.type as PrimitiveType;

      return TextFormField(
        controller: controller,
        onChanged: (value) {
          formState.update(sc.widget.entry.name, safeParseNumber(value));
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
        keyboardType: TextInputType.numberWithOptions(
          decimal: schema.type.startsWith("float"),
          signed: !schema.type.startsWith("u"),
        ),
        inputFormatters: schema.type.startsWith("float")
            ? [
                TextInputFormatter.withFunction(
                  (oldValue, newValue) => (newValue == "" ||
                          RegExp(r'^-?(\d+)(\.\d+)?$').hasMatch(newValue.text))
                      ? newValue
                      : oldValue,
                ),
              ]
            : schema.type.startsWith("u")
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                : [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) => newValue == "" ||
                              RegExp(r'^-?(\d+)$').hasMatch(newValue.text)
                          ? newValue
                          : oldValue,
                    ),
                  ],
        validator: sc.widget.options.validator(sc.widget.entry),
      );
    };
  }
}
