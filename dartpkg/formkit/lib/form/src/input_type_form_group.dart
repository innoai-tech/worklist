import 'package:flutter/material.dart';
import 'package:formkit/form/form.dart';
import 'package:formkit/form/src/ext.dart';
import 'package:setup_widget/setup_widget.dart';

import '../../schema/schema.dart';
import 'common.dart';

class FormGroup extends InputType {
  @override
  build(ctx, entry, {viewMode}) {
    return _Group(entry: entry, viewMode: viewMode);
  }

  validator(entry) {
    return null;
  }
}

class _Group extends SetupWidget<_Group> {
  final Entry entry;
  final bool? viewMode;

  const _Group({
    required this.entry,
    this.viewMode,
  });

  @override
  setup(sc) {
    return () {
      final values = sc.widget.entry.value ?? Map<String, dynamic>.from({});

      return Section(
        label: sc.widget.entry.label?.let(
          (label) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              ...?sc.widget.entry
                  .descriptionWidget(sc.context)
                  ?.let((v) => [v]),
            ],
          ),
        ),
        children: [
          ...sc.widget.entry.type.entries(values, sc.widget.entry.ctx).map(
              (entry) => entry.build(sc.context, viewMode: sc.widget.viewMode)),
        ],
      );
    };
  }
}
