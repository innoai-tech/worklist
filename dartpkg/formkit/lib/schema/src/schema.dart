import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';

import 'ext.dart';
import 'key_path.dart';

part '__generated__/schema.g.dart';

abstract class Schema {
  Map<String, dynamic> get metadata;

  Map<String, Schema> get definitions;

  bool? get nullable;

  Iterable<Entry> entries(dynamic values, EntryContext ctx);

  factory Schema.fromJson(Map<String, dynamic> json) {
    // https://jsontypedef.com/docs/jtd-in-5-minutes/
    final nullable = (json["nullable"] is bool) ? json["nullable"] : null;
    Map<String, Schema> definitions =
        (json["definitions"] as Map? ?? {}).map((key, value) => MapEntry(
              key,
              Schema.fromJson(value as Map<String, dynamic>),
            ));

    Map<String, dynamic> metadata =
        (json["metadata"] is Map) ? json["metadata"] : {};

    if (json["enum"] is List) {
      return EnumType(
        values: json["enum"],
        metadata: metadata,
        nullable: nullable,
      );
    }

    if ((json["properties"] is Map) || json["optionalProperties"] is Map) {
      return ObjectType(
        properties:
            (json["properties"] as Map?)?.let((properties) => properties.map(
                  (key, value) => MapEntry(key, Schema.fromJson(value)),
                )),
        optionalProperties: (json["optionalProperties"] as Map?)
            ?.let((properties) => properties.map(
                  (key, value) => MapEntry(key, Schema.fromJson(value)),
                )),
        additionalProperties: json["additionalProperties"],
        metadata: metadata,
        nullable: nullable,
        definitions: definitions,
      );
    }

    if (json["values"] is Map) {
      return MapType(
        values: Schema.fromJson(json["values"] as Map<String, dynamic>),
        metadata: metadata,
        nullable: nullable,
        definitions: definitions,
      );
    }

    if (json["elements"] is Map) {
      return ArrayType(
        elements: Schema.fromJson(json["elements"] as Map<String, dynamic>),
        metadata: metadata,
        nullable: nullable,
      );
    }

    if (json["discriminator"] is String && json["mapping"] is Map) {
      return TaggedUnionType(
        discriminator: (json["discriminator"] as String),
        mapping: (json["mapping"] as Map).map(
          (key, value) => MapEntry(
            key,
            Schema.fromJson(value) as ObjectType,
          ),
        ),
        metadata: metadata,
        nullable: nullable,
        definitions: definitions,
      );
    }

    if (json["type"] is String) {
      return PrimitiveType(
        type: (json["type"] as String),
        metadata: metadata,
        nullable: nullable,
      );
    }

    if (json["ref"] is String) {
      return RefType(
        ref: json["ref"] as String,
        metadata: metadata,
        nullable: nullable,
        definitions: definitions,
      );
    }

    return AnyType(
      metadata: metadata,
      nullable: nullable,
    );
  }

  static Schema string() {
    return PrimitiveType(type: "string");
  }

  static Schema float64() {
    return PrimitiveType(type: "float64");
  }

  static Schema boolean() {
    return PrimitiveType(type: "boolean");
  }

  static Schema object(Map<String, Schema> properties) {
    return ObjectType(properties: properties);
  }

  static Schema arrayOf(Schema elements) {
    return ArrayType(elements: elements);
  }

  static Schema ref(String ref) {
    return RefType(ref: ref);
  }

  static Schema enums<T>(List<T> values) {
    return EnumType<T>(values: values);
  }
}

class EntryContext {
  final List<dynamic> branch;
  final KeyPath path;
  final Map<String, Schema> definitions;

  EntryContext({
    this.path = const KeyPath(),
    this.branch = const [],
    this.definitions = const {},
  });

  entry({
    required dynamic key,
    dynamic value,
  }) {
    return EntryContext(
      path: this.path.entry(key),
      branch: [...this.branch, value],
      definitions: this.definitions,
    );
  }

  Schema deref(Schema type) {
    if (type is RefType) {
      final found = this.definitions[type.ref];
      if (found == null) {
        throw Exception("undefined ${type.ref}");
      }
      return found.copyWithMetadata(type.metadata);
    }
    return type;
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class Entry {
  final EntryContext scope;
  final Schema type;
  final dynamic value;
  final dynamic key;

  Entry({
    required this.scope,
    required this.type,
    this.key,
    this.value,
  });

  bool get hasValue => !(value == null || value == "");

  KeyPath get name => scope.path.entry(key);

  EntryContext get ctx {
    if (key == null) {
      return scope;
    }
    return scope.entry(key: key, value: value);
  }
}

class SchemaCommon implements Schema {
  final Map<String, dynamic> metadata;
  final bool? nullable;
  final Map<String, Schema> definitions;

  SchemaCommon({
    this.nullable,
    this.metadata = const {},
    this.definitions = const {},
  });

  @override
  Iterable<Entry> entries(values, EntryContext ctx) sync* {}
}

@CopyWith(skipFields: true, copyWithNull: true)
class AnyType extends SchemaCommon {
  AnyType({
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return "any";
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class RefType extends SchemaCommon {
  String ref;

  RefType({
    required this.ref,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return this.ref;
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class EnumType<T> extends SchemaCommon {
  final List<T> values;

  EnumType({
    required this.values,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return this.values.map((e) => jsonEncode(e)).join(" | ");
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class ArrayType extends SchemaCommon {
  final Schema elements;

  ArrayType({
    required this.elements,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return "${this.elements}[]";
  }

  @override
  Iterable<Entry> entries(values, EntryContext ctx) sync* {
    if (values is List) {
      for (var i = 0; i < values.length; i++) {
        yield Entry(
          scope: ctx,
          type: ctx.deref(this.elements),
          key: i,
          value: values[i],
        );
      }
    }
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class MapType extends SchemaCommon {
  final Schema values;

  MapType({
    required this.values,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return "{ [k:string]: ${this.values} }";
  }

  @override
  Iterable<Entry> entries(values, EntryContext ctx) sync* {
    if (values is Map) {
      for (var key in values.keys) {
        yield Entry(
          scope: ctx,
          type: ctx.deref(this.values),
          key: key,
          value: values[key],
        );
      }
    }
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class ObjectType extends SchemaCommon {
  final Map<String, Schema>? properties;
  final Map<String, Schema>? optionalProperties;
  final bool? additionalProperties;

  ObjectType({
    this.properties,
    this.optionalProperties,
    this.additionalProperties,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return "{ ${[
      ...?this.properties?.map((key, s) => MapEntry(key, "$key: $s")).values,
      ...?this
          .optionalProperties
          ?.map((key, s) => MapEntry(key, "$key?: $s"))
          .values,
    ].join(", ")} }";
  }

  @override
  Iterable<Entry> entries(values, EntryContext ctx) sync* {
    if (values is Map) {
      if (this.properties != null) {
        final props = this.properties!;

        for (final key in props.keys) {
          yield Entry(
            scope: ctx,
            type: ctx.deref(props[key]!),
            key: key,
            value: values[key],
          );
        }
      }

      if (this.optionalProperties != null) {
        final props = this.properties!;

        for (final key in props.keys) {
          yield Entry(
            scope: ctx,
            type: ctx.deref(props[key]!).copyWithNullable(true),
            key: key,
            value: values[key],
          );
        }
      }
    }
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class TaggedUnionType extends SchemaCommon {
  final String discriminator;
  final Map<String, ObjectType> mapping;

  TaggedUnionType({
    required this.discriminator,
    required this.mapping,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  Iterable<Entry> entries(values, EntryContext ctx) sync* {
    if (values is Map) {
      final discriminatorValue = values[this.discriminator];
      final discriminatorMetadata =
          get(this.metadata, KeyPath.from(["discriminator", "metadata"])) ?? {};
      final discriminatorLabels = this.metadata["mappingLabels"] ?? {};
      final enumValues = [...this.mapping.keys];

      yield Entry(
        scope: ctx,
        type: EnumType<String>(
          values: enumValues,
          metadata: {
            ...discriminatorMetadata,
            "enumLabels":
                enumValues.map((e) => discriminatorLabels[e] ?? e).toList(),
          },
        ),
        key: this.discriminator,
        value: discriminatorValue,
      );

      if (discriminatorValue != null &&
          this.mapping[discriminatorValue] != null) {
        yield* this.mapping[discriminatorValue]!.entries(values, ctx);
      }
    }
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
class PrimitiveType extends SchemaCommon {
  final String type;

  PrimitiveType({
    required this.type,
    super.metadata,
    super.nullable,
    super.definitions,
  });

  @override
  String toString() {
    return this.type;
  }
}

extension CopyExt on Schema {
  Schema copyWithDefinitions(Map<String, Schema> definitions) {
    return switch (this) {
      AnyType x => x.copyWith(definitions: definitions),
      EnumType x => x.copyWith(definitions: definitions),
      RefType x => x.copyWith(definitions: definitions),
      PrimitiveType x => x.copyWith(definitions: definitions),
      ArrayType x => x.copyWith(definitions: definitions),
      ObjectType x => x.copyWith(definitions: definitions),
      MapType x => x.copyWith(definitions: definitions),
      TaggedUnionType x => x.copyWith(definitions: definitions),
      Schema() => this,
    };
  }

  Schema copyWithNullable(bool? nullable) {
    return switch (this) {
      AnyType x => x.copyWith(nullable: nullable),
      EnumType x => x.copyWith(nullable: nullable),
      RefType x => x.copyWith(nullable: nullable),
      PrimitiveType x => x.copyWith(nullable: nullable),
      ArrayType x => x.copyWith(nullable: nullable),
      ObjectType x => x.copyWith(nullable: nullable),
      MapType x => x.copyWith(nullable: nullable),
      TaggedUnionType x => x.copyWith(nullable: nullable),
      Schema() => this,
    };
  }

  Schema copyWithMetadata(Map<String, dynamic> metadata) {
    return switch (this) {
      AnyType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      EnumType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      RefType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      PrimitiveType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      ArrayType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      ObjectType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      MapType x => x.copyWith(metadata: {...this.metadata, ...metadata}),
      TaggedUnionType x =>
        x.copyWith(metadata: {...this.metadata, ...metadata}),
      Schema() => this,
    };
  }
}
