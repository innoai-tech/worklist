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

part '__generated__/input_type_selector.g.dart';

@JsonSerializable()
class Option {
  final dynamic value;
  final String label;

  const Option({
    required this.label,
    required this.value,
  });

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@JsonSerializable()
class Selector implements InputType {
  final List<Option> options;

  const Selector({
    required this.options,
  });

  @override
  build(ctx, entry, {viewMode}) {
    if (viewMode ?? false) {
      if (viewMode ?? false) {
        return InputView(
          label: Text("${entry.label ?? entry.key}"),
          validator: validator(entry),
          value: entry.value,
          builder: (value) {
            return Text(
                "${options.where((o) => o.value == value).firstOrNull?.label ?? ""}");
          },
        );
      }
    }
    return _FormField(entry: entry, options: this);
  }

  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);

  @override
  validator(entry) {
    return compose([
      ...?entry.optional.ifFalse(() => [validateRequired()]),
      (dynamic value) {
        if (options.where((o) => o.value == entry.value).firstOrNull == null) {
          return "不是合法的值";
        }
        return null;
      }
    ]);
  }
}

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final Selector options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final formFieldKey = GlobalKey<FormFieldState<String?>>();

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      formFieldKey.currentState?.didChange(newValue);
    }).listenOnMountedUntilUnmounted();

    return () {
      return FormField(
        key: formFieldKey,
        initialValue: sc.widget.entry.value,
        validator: sc.widget.options.validator(sc.widget.entry),
        onSaved: (value) {
          formState.update(sc.widget.entry.name, value);
        },
        builder: (formFieldState) {
          return InputDecorator(
            decoration: entry.inputDecoration(
              sc.context,
              errorText: formFieldState.errorText,
              suffixIcon: sc.widget.entry.descriptionWidget(sc.context),
            ),
            isEmpty: formFieldState.value == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: formFieldState.value,
                isDense: true,
                onChanged: (newValue) {
                  formFieldState.didChange(newValue);
                  formFieldState.save();
                },
                items: [
                  ...?sc.widget.entry.optional.ifTrue(() => [
                        DropdownMenuItem(
                          value: null,
                          child: Text("选择"),
                        )
                      ]),
                  ...sc.widget.options.options.map((o) {
                    return DropdownMenuItem(
                      value: o.value,
                      child: Text(o.label),
                    );
                  })
                ],
              ),
            ),
          );
        },
      );
    };
  }
}
