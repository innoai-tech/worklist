// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../errcode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrTagUnknown _$ErrTagUnknownFromJson(Map<String, dynamic> json) =>
    ErrTagUnknown(
      tag: json['tag'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ErrTagUnknownToJson(ErrTagUnknown instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'name': instance.name,
    };

ErrManifestUnknownRevision _$ErrManifestUnknownRevisionFromJson(
        Map<String, dynamic> json) =>
    ErrManifestUnknownRevision(
      revision: json['revision'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ErrManifestUnknownRevisionToJson(
        ErrManifestUnknownRevision instance) =>
    <String, dynamic>{
      'revision': instance.revision,
      'name': instance.name,
    };
