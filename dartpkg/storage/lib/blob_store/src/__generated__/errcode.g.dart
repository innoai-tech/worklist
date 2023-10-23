// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../errcode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrBlobUnknown _$ErrBlobUnknownFromJson(Map<String, dynamic> json) =>
    ErrBlobUnknown(
      digest: Digest.fromJson(json['digest'] as String),
      path: json['path'] as String?,
    );

Map<String, dynamic> _$ErrBlobUnknownToJson(ErrBlobUnknown instance) =>
    <String, dynamic>{
      'digest': instance.digest,
      'path': instance.path,
    };

ErrDigestNotMatch _$ErrDigestNotMatchFromJson(Map<String, dynamic> json) =>
    ErrDigestNotMatch(
      expected: Digest.fromJson(json['expected'] as String),
      got: Digest.fromJson(json['got'] as String),
    );

Map<String, dynamic> _$ErrDigestNotMatchToJson(ErrDigestNotMatch instance) =>
    <String, dynamic>{
      'expected': instance.expected,
      'got': instance.got,
    };
