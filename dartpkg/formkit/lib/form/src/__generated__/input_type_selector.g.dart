// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../input_type_selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Option _$OptionFromJson(Map<String, dynamic> json) => Option(
      label: json['label'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$OptionToJson(Option instance) => <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
    };

Selector _$SelectorFromJson(Map<String, dynamic> json) => Selector(
      options: (json['options'] as List<dynamic>)
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SelectorToJson(Selector instance) => <String, dynamic>{
      'options': instance.options,
    };
