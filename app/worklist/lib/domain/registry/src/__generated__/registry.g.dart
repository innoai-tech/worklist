// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../registry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegistryCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Registry(...).copyWith(id: 12, name: "My name")
  /// ````
  Registry call({
    String? endpoint,
    String? username,
    String? password,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegistry.copyWith(...)`.
class _$RegistryCWProxyImpl implements _$RegistryCWProxy {
  const _$RegistryCWProxyImpl(this._value);

  final Registry _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Registry(...).copyWith(id: 12, name: "My name")
  /// ````
  Registry call({
    Object? endpoint = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return Registry(
      endpoint: endpoint == const $CopyWithPlaceholder() || endpoint == null
          ? _value.endpoint
          // ignore: cast_nullable_to_non_nullable
          : endpoint as String,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
    );
  }
}

extension $RegistryCopyWith on Registry {
  /// Returns a callable class that can be used as follows: `instanceOfRegistry.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RegistryCWProxy get copyWith => _$RegistryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Registry _$RegistryFromJson(Map<String, dynamic> json) => Registry(
      endpoint: json['endpoint'] as String,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$RegistryToJson(Registry instance) {
  final val = <String, dynamic>{
    'endpoint': instance.endpoint,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('username', instance.username);
  writeNotNull('password', instance.password);
  return val;
}
