// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../status_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDescriptor _$ErrorDescriptorFromJson(Map<String, dynamic> json) =>
    ErrorDescriptor(
      code: json['code'] as String,
      message: json['message'] as String,
      detail: json['detail'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ErrorDescriptorToJson(ErrorDescriptor instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'detail': instance.detail,
    };
