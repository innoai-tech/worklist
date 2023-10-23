// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../schema.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntryCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Entry(...).copyWith(id: 12, name: "My name")
  /// ````
  Entry call({
    EntryContext? scope,
    Schema? type,
    dynamic key,
    dynamic value,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntry.copyWith(...)`.
class _$EntryCWProxyImpl implements _$EntryCWProxy {
  const _$EntryCWProxyImpl(this._value);

  final Entry _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Entry(...).copyWith(id: 12, name: "My name")
  /// ````
  Entry call({
    Object? scope = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? key = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return Entry(
      scope: scope == const $CopyWithPlaceholder() || scope == null
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as EntryContext,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as Schema,
      key: key == const $CopyWithPlaceholder() || key == null
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as dynamic,
      value: value == const $CopyWithPlaceholder() || value == null
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as dynamic,
    );
  }
}

extension $EntryCopyWith on Entry {
  /// Returns a callable class that can be used as follows: `instanceOfEntry.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$EntryCWProxy get copyWith => _$EntryCWProxyImpl(this);
}

abstract class _$AnyTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AnyType(...).copyWith(id: 12, name: "My name")
  /// ````
  AnyType call({
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnyType.copyWith(...)`.
class _$AnyTypeCWProxyImpl implements _$AnyTypeCWProxy {
  const _$AnyTypeCWProxyImpl(this._value);

  final AnyType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AnyType(...).copyWith(id: 12, name: "My name")
  /// ````
  AnyType call({
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return AnyType(
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $AnyTypeCopyWith on AnyType {
  /// Returns a callable class that can be used as follows: `instanceOfAnyType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AnyTypeCWProxy get copyWith => _$AnyTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// AnyType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  AnyType copyWithNull({
    bool nullable = false,
  }) {
    return AnyType(
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$RefTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RefType(...).copyWith(id: 12, name: "My name")
  /// ````
  RefType call({
    String? ref,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefType.copyWith(...)`.
class _$RefTypeCWProxyImpl implements _$RefTypeCWProxy {
  const _$RefTypeCWProxyImpl(this._value);

  final RefType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RefType(...).copyWith(id: 12, name: "My name")
  /// ````
  RefType call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return RefType(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as String,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $RefTypeCopyWith on RefType {
  /// Returns a callable class that can be used as follows: `instanceOfRefType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RefTypeCWProxy get copyWith => _$RefTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// RefType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  RefType copyWithNull({
    bool nullable = false,
  }) {
    return RefType(
      ref: ref,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$EnumTypeCWProxy<T> {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// EnumType<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  EnumType<T> call({
    List<T>? values,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnumType.copyWith(...)`.
class _$EnumTypeCWProxyImpl<T> implements _$EnumTypeCWProxy<T> {
  const _$EnumTypeCWProxyImpl(this._value);

  final EnumType<T> _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// EnumType<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  EnumType<T> call({
    Object? values = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return EnumType<T>(
      values: values == const $CopyWithPlaceholder() || values == null
          ? _value.values
          // ignore: cast_nullable_to_non_nullable
          : values as List<T>,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $EnumTypeCopyWith<T> on EnumType<T> {
  /// Returns a callable class that can be used as follows: `instanceOfEnumType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$EnumTypeCWProxy<T> get copyWith => _$EnumTypeCWProxyImpl<T>(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// EnumType<T>(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  EnumType<T> copyWithNull({
    bool nullable = false,
  }) {
    return EnumType<T>(
      values: values,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$ArrayTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ArrayType(...).copyWith(id: 12, name: "My name")
  /// ````
  ArrayType call({
    Schema? elements,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfArrayType.copyWith(...)`.
class _$ArrayTypeCWProxyImpl implements _$ArrayTypeCWProxy {
  const _$ArrayTypeCWProxyImpl(this._value);

  final ArrayType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ArrayType(...).copyWith(id: 12, name: "My name")
  /// ````
  ArrayType call({
    Object? elements = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return ArrayType(
      elements: elements == const $CopyWithPlaceholder() || elements == null
          ? _value.elements
          // ignore: cast_nullable_to_non_nullable
          : elements as Schema,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $ArrayTypeCopyWith on ArrayType {
  /// Returns a callable class that can be used as follows: `instanceOfArrayType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ArrayTypeCWProxy get copyWith => _$ArrayTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// ArrayType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  ArrayType copyWithNull({
    bool nullable = false,
  }) {
    return ArrayType(
      elements: elements,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$MapTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// MapType(...).copyWith(id: 12, name: "My name")
  /// ````
  MapType call({
    Schema? values,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMapType.copyWith(...)`.
class _$MapTypeCWProxyImpl implements _$MapTypeCWProxy {
  const _$MapTypeCWProxyImpl(this._value);

  final MapType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// MapType(...).copyWith(id: 12, name: "My name")
  /// ````
  MapType call({
    Object? values = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return MapType(
      values: values == const $CopyWithPlaceholder() || values == null
          ? _value.values
          // ignore: cast_nullable_to_non_nullable
          : values as Schema,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $MapTypeCopyWith on MapType {
  /// Returns a callable class that can be used as follows: `instanceOfMapType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$MapTypeCWProxy get copyWith => _$MapTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// MapType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  MapType copyWithNull({
    bool nullable = false,
  }) {
    return MapType(
      values: values,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$ObjectTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ObjectType(...).copyWith(id: 12, name: "My name")
  /// ````
  ObjectType call({
    Map<String, Schema>? properties,
    Map<String, Schema>? optionalProperties,
    bool? additionalProperties,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfObjectType.copyWith(...)`.
class _$ObjectTypeCWProxyImpl implements _$ObjectTypeCWProxy {
  const _$ObjectTypeCWProxyImpl(this._value);

  final ObjectType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ObjectType(...).copyWith(id: 12, name: "My name")
  /// ````
  ObjectType call({
    Object? properties = const $CopyWithPlaceholder(),
    Object? optionalProperties = const $CopyWithPlaceholder(),
    Object? additionalProperties = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return ObjectType(
      properties: properties == const $CopyWithPlaceholder()
          ? _value.properties
          // ignore: cast_nullable_to_non_nullable
          : properties as Map<String, Schema>?,
      optionalProperties: optionalProperties == const $CopyWithPlaceholder()
          ? _value.optionalProperties
          // ignore: cast_nullable_to_non_nullable
          : optionalProperties as Map<String, Schema>?,
      additionalProperties: additionalProperties == const $CopyWithPlaceholder()
          ? _value.additionalProperties
          // ignore: cast_nullable_to_non_nullable
          : additionalProperties as bool?,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $ObjectTypeCopyWith on ObjectType {
  /// Returns a callable class that can be used as follows: `instanceOfObjectType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ObjectTypeCWProxy get copyWith => _$ObjectTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// ObjectType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  ObjectType copyWithNull({
    bool properties = false,
    bool optionalProperties = false,
    bool additionalProperties = false,
    bool nullable = false,
  }) {
    return ObjectType(
      properties: properties == true ? null : this.properties,
      optionalProperties:
          optionalProperties == true ? null : this.optionalProperties,
      additionalProperties:
          additionalProperties == true ? null : this.additionalProperties,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$TaggedUnionTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TaggedUnionType(...).copyWith(id: 12, name: "My name")
  /// ````
  TaggedUnionType call({
    String? discriminator,
    Map<String, ObjectType>? mapping,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTaggedUnionType.copyWith(...)`.
class _$TaggedUnionTypeCWProxyImpl implements _$TaggedUnionTypeCWProxy {
  const _$TaggedUnionTypeCWProxyImpl(this._value);

  final TaggedUnionType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TaggedUnionType(...).copyWith(id: 12, name: "My name")
  /// ````
  TaggedUnionType call({
    Object? discriminator = const $CopyWithPlaceholder(),
    Object? mapping = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return TaggedUnionType(
      discriminator:
          discriminator == const $CopyWithPlaceholder() || discriminator == null
              ? _value.discriminator
              // ignore: cast_nullable_to_non_nullable
              : discriminator as String,
      mapping: mapping == const $CopyWithPlaceholder() || mapping == null
          ? _value.mapping
          // ignore: cast_nullable_to_non_nullable
          : mapping as Map<String, ObjectType>,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $TaggedUnionTypeCopyWith on TaggedUnionType {
  /// Returns a callable class that can be used as follows: `instanceOfTaggedUnionType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TaggedUnionTypeCWProxy get copyWith => _$TaggedUnionTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// TaggedUnionType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  TaggedUnionType copyWithNull({
    bool nullable = false,
  }) {
    return TaggedUnionType(
      discriminator: discriminator,
      mapping: mapping,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}

abstract class _$PrimitiveTypeCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// PrimitiveType(...).copyWith(id: 12, name: "My name")
  /// ````
  PrimitiveType call({
    String? type,
    Map<String, dynamic>? metadata,
    bool? nullable,
    Map<String, Schema>? definitions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrimitiveType.copyWith(...)`.
class _$PrimitiveTypeCWProxyImpl implements _$PrimitiveTypeCWProxy {
  const _$PrimitiveTypeCWProxyImpl(this._value);

  final PrimitiveType _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// PrimitiveType(...).copyWith(id: 12, name: "My name")
  /// ````
  PrimitiveType call({
    Object? type = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? nullable = const $CopyWithPlaceholder(),
    Object? definitions = const $CopyWithPlaceholder(),
  }) {
    return PrimitiveType(
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      nullable: nullable == const $CopyWithPlaceholder()
          ? _value.nullable
          // ignore: cast_nullable_to_non_nullable
          : nullable as bool?,
      definitions:
          definitions == const $CopyWithPlaceholder() || definitions == null
              ? _value.definitions
              // ignore: cast_nullable_to_non_nullable
              : definitions as Map<String, Schema>,
    );
  }
}

extension $PrimitiveTypeCopyWith on PrimitiveType {
  /// Returns a callable class that can be used as follows: `instanceOfPrimitiveType.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$PrimitiveTypeCWProxy get copyWith => _$PrimitiveTypeCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// PrimitiveType(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  PrimitiveType copyWithNull({
    bool nullable = false,
  }) {
    return PrimitiveType(
      type: type,
      metadata: metadata,
      nullable: nullable == true ? null : this.nullable,
      definitions: definitions,
    );
  }
}
