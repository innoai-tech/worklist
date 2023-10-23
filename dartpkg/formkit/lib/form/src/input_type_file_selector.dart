import 'dart:io';

import 'package:flutter/material.dart' hide FormState;
import 'package:formkit/schema/schema.dart';
import 'package:formkit/validator/validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'ext.dart';
import 'form.dart';
import 'input_type.dart';

part '__generated__/input_type_file_selector.g.dart';

@JsonSerializable()
class FileSelector implements InputType {
  final String? accept;
  final bool? multiple;

  const FileSelector({
    this.accept,
    this.multiple,
  });

  @override
  build(ctx, entry, {viewMode}) {
    return _FormField(entry: entry, options: this);
  }

  validator(entry) {
    return null;
  }

  factory FileSelector.fromJson(Map<String, dynamic> json) =>
      _$FileSelectorFromJson(json);
}

class _FormField extends SetupWidget<_FormField> {
  final Entry entry;
  final FileSelector options;

  _FormField({
    required this.entry,
    required this.options,
  });

  @override
  setup(sc) {
    final formState = FormState.context.use();

    final ImagePicker picker = ImagePicker();

    pickImage({required Function(Uri fileURI) onSelected}) async {
      try {
        final XFile? img = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (img != null) {
          onSelected(Uri.file(img.path));
        }
      } catch (err) {
        print(err);
      }
    }

    final formFieldKey = GlobalKey<FormFieldState<String?>>();

    toObservable(() => sc.widget.entry.value).doOnData((newValue) {
      formFieldKey.currentState?.didChange(newValue);
    }).listenOnMountedUntilUnmounted();

    return () {
      final isImage = sc.widget.options.accept?.startsWith("image/") ?? false;

      return FormField<String?>(
        key: formFieldKey,
        initialValue: sc.widget.entry.value,
        onSaved: (value) {
          formState.update(sc.widget.entry.name, value);
        },
        validator: compose([
          ...?sc.widget.entry.optional.ifFalse(() => [validateRequired()]),
        ]),
        builder: (fieldState) {
          if (fieldState.value == null) {
            pickImage(
              onSelected: (uri) => {
                fieldState.didChange(uri.toString()),
                fieldState.save(),
              },
            );

            return SizedBox.shrink();
          }

          return Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              Image.file(File(Uri.parse(fieldState.value!).path)),
            ],
          );
        },
      );
    };
  }
}
