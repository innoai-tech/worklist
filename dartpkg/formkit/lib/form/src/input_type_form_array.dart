import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide FormState, Form;
import 'package:formkit/form/src/ext.dart';
import 'package:formkit/schema/schema.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'common.dart';
import 'form.dart';
import 'input_type.dart';
import 'input_type_ext.dart';

class FormArray extends InputType {
  @override
  build(ctx, entry, {viewMode}) {
    return _Array(entry: entry, viewMode: viewMode);
  }

  validator(entry) {
    return null;
  }
}

class _Array extends SetupWidget<_Array> {
  final Entry entry;
  final bool? viewMode;

  const _Array({
    required this.entry,
    this.viewMode,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final formFieldKey = GlobalKey<FormFieldState<List>>(
      debugLabel: "${sc.widget.entry.name}",
    );

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      formFieldKey.currentState?.didChange(newValue);
    }).listenOnMountedUntilUnmounted();

    final showSubForm = (int? idx) {
      final route = MaterialPageRoute(builder: (ctx) {
        final entry = sc.widget.entry;

        return Form(
          schema: Schema.object({
            "values": entry.ctx.deref((entry.type as ArrayType).elements),
          }).copyWithDefinitions(entry.ctx.definitions),
          initialValues: {
            "values":
                idx != null ? get(entry.value, KeyPath.from([idx])) : null,
          },
          builder: (ctx, formState, fields) {
            return Scaffold(
              appBar: AppBar(
                title: Text(entry.label ?? entry.key),
                actions: [
                  ...?(idx is int).ifTrue(() => [
                        IconButton(
                          onPressed: () {
                            showPrompt(
                                context: sc.context,
                                contents: Text("是否删除当前${entry.label ?? "key"}"),
                                onConfirm: () {
                                  formFieldKey.currentState?.didChange([
                                    ...?formFieldKey.currentState?.value
                                        ?.slice(0, idx),
                                    ...?formFieldKey.currentState?.value
                                        ?.slice(idx! + 1),
                                  ]);
                                  formFieldKey.currentState?.save();

                                  Navigator.of(ctx).pop();
                                });
                          },
                          icon: Icon(Icons.delete_outline),
                        )
                      ]),
                  IconButton(
                    onPressed: () {
                      if (formState.validate()) {
                        final newValues = formState.values()["values"];

                        if (idx == null) {
                          formFieldKey.currentState?.didChange([
                            ...?formFieldKey.currentState?.value,
                            newValues,
                          ]);
                        } else {
                          formFieldKey.currentState?.didChange([
                            ...?formFieldKey.currentState?.value?.mapIndexed((
                              i,
                              v,
                            ) {
                              if (i == idx) {
                                return newValues;
                              }
                              return v;
                            })
                          ]);
                        }

                        formFieldKey.currentState?.save();

                        Navigator.of(ctx).pop();
                      }
                    },
                    icon: Icon(Icons.done),
                  )
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: fields,
                  ),
                ),
              ),
            );
          },
        );
      });

      Navigator.of(sc.context).push(route);
    };

    return () {
      return FormField<List>(
        key: formFieldKey,
        initialValue: sc.widget.entry.value ?? [],
        onSaved: (value) {
          formState.update(sc.widget.entry.name, value);
        },
        builder: (fieldState) {
          return Section(
            label: sc.widget.entry.label?.let((label) => Text(label)),
            actions: [
              ...?(sc.widget.viewMode ?? false).ifFalse(() => [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showSubForm(null);
                      },
                    ),
                    ...?sc.widget.entry
                        .descriptionWidget(sc.context)
                        ?.let((v) => [v]),
                  ])
            ],
            children: [
              ...sc.widget.entry.type
                  .entries(fieldState.value, sc.widget.entry.ctx)
                  .mapIndexed((i, entry) => [
                        Divider(thickness: 0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: entry.build(sc.context, viewMode: true)),
                            ...?(sc.widget.viewMode ?? false).ifFalse(() => [
                                  IconButton(
                                    onPressed: () {
                                      showSubForm(i);
                                    },
                                    icon: Icon(Icons.edit_outlined),
                                  )
                                ])
                          ],
                        ),
                      ])
                  .flattened,
            ],
          );
        },
      );
    };
  }
}

final showPrompt = ({
  required BuildContext context,
  required Widget contents,
  Widget? title,
  Function? onConfirm,
  Function? onCancel,
}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: contents,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
                onCancel?.let((onCancel) => onCancel());
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.let((onConfirm) => onConfirm());
              },
            ),
          ],
        );
      });
};
