import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "__generated__/worklist_schema.g.dart";

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true)
class WorklistSchema {
  final String endpoint;
  final String name;
  final String? version;

  WorklistSchema({
    required this.endpoint,
    required this.name,
    this.version,
  });

  String get key => "${this.endpoint}/${this.name}";

  @override
  toString() {
    return "${key}:${version ?? "latest"}";
  }

  factory WorklistSchema.fromJson(Map<String, dynamic> json) =>
      _$WorklistSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$WorklistSchemaToJson(this);
}
