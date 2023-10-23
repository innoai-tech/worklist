import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/spec/spec.dart';
import 'package:uuid/uuid.dart';

import 'worklist_schema.dart';

part "__generated__/worklist.g.dart";

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true, copyWithNull: true)
class Worklist {
  factory Worklist.fromSchema(WorklistSchemaIdentity schema) {
    return Worklist(
      id: Uuid().v4(),
      schema: schema,
    );
  }

  final String id;
  final WorklistSchemaIdentity schema;
  final Map<String, dynamic>? latestValues;
  final Map<String, dynamic>? validValues;
  final Digest? digest;
  final Digest? latestSynced;

  Worklist({
    required this.id,
    required this.schema,
    this.latestValues,
    this.validValues,
    this.digest,
    this.latestSynced,
  });

  factory Worklist.fromJson(Map<String, dynamic> json) =>
      _$WorklistFromJson(json);

  bool get syncable {
    return this.digest != null && this.digest != this.latestSynced;
  }

  bool get synced {
    return this.digest != null && this.digest == this.latestSynced;
  }

  String get name => initialValues["name"] ?? id;

  Map<String, dynamic> toJson() => _$WorklistToJson(this);

  Map<String, dynamic> get initialValues => validValues ?? latestValues ?? {};
}
