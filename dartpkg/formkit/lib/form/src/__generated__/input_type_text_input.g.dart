// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../input_type_text_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextInput _$TextInputFromJson(Map<String, dynamic> json) => TextInput(
      mask: json['mask'] as String?,
      pattern: json['pattern'] as String?,
      format: json['format'] as String?,
      minChars: json['minChars'] as int?,
      maxChars: json['maxChars'] as int?,
    );

Map<String, dynamic> _$TextInputToJson(TextInput instance) => <String, dynamic>{
      'pattern': instance.pattern,
      'format': instance.format,
      'minChars': instance.minChars,
      'maxChars': instance.maxChars,
      'mask': instance.mask,
    };
