import 'package:flutter/material.dart' hide FormField;
import 'package:formkit/schema/schema.dart';

import '../../mdview/mdview.dart';

abstract class InputType {
  Widget build(BuildContext ctx, Entry entry, {bool? viewMode});

  FormFieldValidator? validator(Entry entry);
}

extension EntryWithWidgetExt on Entry {
  InputDecoration inputDecoration(
    BuildContext ctx, {
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      label: Text(label ?? key),
      helperText: hint,
      border: OutlineInputBorder(),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      isDense: true,
      errorText: errorText,
      suffixIcon: suffixIcon,
    );
  }

  Widget? descriptionWidget(BuildContext context) {
    if (description != null) {
      return IconButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (ctx) {
                return MdView(code: description!);
              });
        },
        icon: Icon(Icons.help_outline),
      );
    }
    return null;
  }
}
