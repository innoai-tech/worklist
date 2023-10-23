import 'package:flutter/material.dart' hide FormState;
import 'package:formkit/form/src/common.dart';
import 'package:formkit/schema/schema.dart';
import 'package:formkit/validator/validator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'ext.dart';
import 'form.dart';
import 'input_type.dart';

part '__generated__/input_type_datetime_picker.g.dart';

@JsonSerializable()
class DatetimePicker implements InputType {
  final String? format;
  final String? min;
  final String? max;

  const DatetimePicker({
    this.format,
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
            return Text(formatDateTime(safeParseDate(value)));
          }
          return Text("");
        },
      );
    }
    return _FormField(entry: entry, options: this);
  }

  validator(entry) {
    return compose([
      ...?entry.optional.ifFalse(() => [validateRequired()]),
    ]);
    ;
  }

  factory DatetimePicker.fromJson(Map<String, dynamic> json) =>
      _$DatetimePickerFromJson(json);

  String get pattern => format ?? 'yyyy-MM-dd HH:mm';

  String formatDateTime(DateTime date, {String? locale}) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(date.toLocal());
  }
}

final safeParseDate = (dynamic value) {
  try {
    return DateTime.parse(value);
  } catch (e) {}
  return DateTime.now();
};

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final DatetimePicker options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final valueToLabel = (dynamic value) {
      return sc.widget.options.formatDateTime(safeParseDate(value));
    };

    final initial = sc.widget.entry.value ?? DateTime.now().toIso8601String();

    final controller = TextEditingController(text: valueToLabel(initial));

    final formFieldKey = GlobalKey<FormFieldState<String?>>();

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      formFieldKey.currentState?.didChange(newValue);
      controller.text = valueToLabel(newValue);
    }).listenOnMountedUntilUnmounted();

    final clearValue = () {
      controller.clear();
      formState.update(sc.widget.entry.name, null);
    };

    return () {
      return FormField<String>(
        key: formFieldKey,
        initialValue: initial,
        validator: sc.widget.options.validator(sc.widget.entry),
        onSaved: (value) {
          controller.text = valueToLabel(value);
          formState.update(sc.widget.entry.name, value);
        },
        builder: (formFieldState) {
          return TextField(
            controller: controller,
            decoration: sc.widget.entry.inputDecoration(
              sc.context,
              errorText: formFieldState.errorText,
              suffixIcon: sc.widget.entry.hasValue.ifTrue(
                    () => IconButton(
                      onPressed: clearValue,
                      icon: Icon(Icons.clear),
                    ),
                  ) ??
                  sc.widget.entry.descriptionWidget(sc.context),
            ),
            readOnly: true,
            onTap: () {
              final datetime = safeParseDate(formFieldState.value!);

              showDateTimePicker(
                      context: sc.context,
                      initialDate: datetime,
                      dateOnly: DateFormat(sc.widget.options.pattern).dateOnly)
                  .then((value) {
                if (value != null) {
                  formFieldState.didChange(value.toUtc().toIso8601String());
                  formFieldState.save();
                }
              });
            },
          );
        },
      );
    };
  }
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  bool? dateOnly,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  if (dateOnly ?? false) {
    return selectedDate;
  }

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
