// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../descriptor.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DescriptorCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Descriptor(...).copyWith(id: 12, name: "My name")
  /// ````
  Descriptor call({
    Map<String, String>? annotations,
    Digest? digest,
    String? mediaType,
    Platform? platform,
    int? size,
    Stream<List<int>>? stream,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDescriptor.copyWith(...)`.
class _$DescriptorCWProxyImpl implements _$DescriptorCWProxy {
  final Descriptor _value;

  const _$DescriptorCWProxyImpl(this._value);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Descriptor(...).copyWith(id: 12, name: "My name")
  /// ````
  Descriptor call({
    Object? annotations = const $CopyWithPlaceholder(),
    Object? digest = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? stream = const $CopyWithPlaceholder(),
  }) {
    return Descriptor(
      annotations: annotations == const $CopyWithPlaceholder()
          ? _value.annotations
          // ignore: cast_nullable_to_non_nullable
          : annotations as Map<String, String>?,
      digest: digest == const $CopyWithPlaceholder()
          ? _value.digest
          // ignore: cast_nullable_to_non_nullable
          : digest as Digest?,
      mediaType: mediaType == const $CopyWithPlaceholder()
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as String?,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as Platform?,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int?,
      stream: stream == const $CopyWithPlaceholder()
          ? _value.stream
          // ignore: cast_nullable_to_non_nullable
          : stream as Stream<List<int>>?,
    );
  }
}

extension $DescriptorCopyWith on Descriptor {
  /// Returns a callable class that can be used as follows: `instanceOfDescriptor.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$DescriptorCWProxy get copyWith => _$DescriptorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Descriptor _$DescriptorFromJson(Map<String, dynamic> json) => Descriptor(
      mediaType: json['mediaType'] as String?,
      digest: json['digest'] == null
          ? null
          : Digest.fromJson(json['digest'] as String),
      size: json['size'] as int?,
      annotations: (json['annotations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      platform: json['platform'] == null
          ? null
          : Platform.fromJson(json['platform'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DescriptorToJson(Descriptor instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('mediaType', instance.mediaType);
  writeNotNull('annotations', instance.annotations);
  writeNotNull('platform', instance.platform);
  writeNotNull('digest', instance.digest);
  writeNotNull('size', instance.size);
  return val;
}

Platform _$PlatformFromJson(Map<String, dynamic> json) => Platform(
      os: json['os'] as String,
      architecture: json['architecture'] as String,
      variant: json['variant'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      osVersion: json['os.version'] as String?,
      osFeatures: (json['os.features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PlatformToJson(Platform instance) => <String, dynamic>{
      'architecture': instance.architecture,
      'os': instance.os,
      'variant': instance.variant,
      'features': instance.features,
      'os.version': instance.osVersion,
      'os.features': instance.osFeatures,
    };
