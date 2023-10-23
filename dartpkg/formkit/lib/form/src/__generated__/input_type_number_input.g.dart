// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../input_type_number_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NumberInput _$NumberInputFromJson(Map<String, dynamic> json) => NumberInput(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NumberInputToJson(NumberInput instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
