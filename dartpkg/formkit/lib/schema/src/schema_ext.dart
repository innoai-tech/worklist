import 'schema.dart';

extension SchemaMetaExt on Schema {
  Schema optional() {
    return this.copyWithNullable(true);
  }

  Schema described({
    required String label,
    String? hint,
    String? description,
  }) {
    return this.copyWithMetadata({
      "label": label,
      "hint": hint,
      "description": description,
    });
  }
}

extension SchemaFieldMetaExt on Entry {
  bool get optional => type.nullable == true;

  String? get description => type.metadata["description"];

  String? get label => type.metadata["label"];

  String? get hint => type.metadata["hint"];
}
