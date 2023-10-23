import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/spec/spec.dart';

part "__generated__/worklist_schema.g.dart";

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true, copyWithNull: true)
class WorklistSchemaIdentity {
  final String endpoint;
  final String name;
  final String? version;

  WorklistSchemaIdentity({
    required this.endpoint,
    required this.name,
    this.version,
  });

  String get key => "${this.endpoint}/${this.name}";

  factory WorklistSchemaIdentity.fromJson(Map<String, dynamic> json) =>
      _$WorklistSchemaIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$WorklistSchemaIdentityToJson(this);
}

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true, copyWithNull: true)
class WorklistSchema extends WorklistSchemaIdentity {
  final String? description;
  final Digest? digest;

  WorklistSchema({
    required super.endpoint,
    required super.name,
    super.version,
    this.description,
    this.digest,
  });

  String get displayName => description ?? name;

  @override
  toString() {
    return "${key}:${version ?? "latest"}";
  }

  factory WorklistSchema.fromJson(Map<String, dynamic> json) =>
      _$WorklistSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$WorklistSchemaToJson(this);
}
