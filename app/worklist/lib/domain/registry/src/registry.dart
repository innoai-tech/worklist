import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "__generated__/registry.g.dart";

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true, copyWithNull: true)
class Registry {
  final String endpoint;
  final String? username;
  final String? password;
  final bool? isDefault;

  Registry({
    required this.endpoint,
    this.username,
    this.password,
    this.isDefault,
  });

  String get key => this.endpoint;

  factory Registry.fromJson(Map<String, dynamic> json) =>
      _$RegistryFromJson(json);

  Map<String, dynamic> toJson() => _$RegistryToJson(this);

  factory Registry.fromURI(Uri endpoint) {
    return Registry(
      endpoint:
          "${endpoint.scheme == "" ? "https" : endpoint.scheme}://${endpoint.host}",
    );
  }
}
