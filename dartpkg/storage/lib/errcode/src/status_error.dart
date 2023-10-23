import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part '__generated__/status_error.g.dart';

class StatusErrors {
  final List<StatusError> errors;

  const StatusErrors({
    required this.errors,
  });

  factory StatusErrors.fromJson(List<dynamic> json) => StatusErrors(
        errors: json.map((e) => ErrorDescriptor.fromJson(e)).toList(),
      );

  List<dynamic> toJson() => this
      .errors
      .map((e) => ErrorDescriptor(
            code: e.code,
            message: e.toString(),
            detail: e.toJson(),
          ).toJson())
      .toList();
}

abstract class StatusError implements Exception {
  int get status;

  String get code;

  Map<String, dynamic>? toJson();
}

@JsonSerializable()
class ErrorDescriptor implements StatusError {
  final String code;
  final String message;
  final Map<String, dynamic>? detail;

  const ErrorDescriptor({
    required this.code,
    required this.message,
    this.detail,
  });

  factory ErrorDescriptor.fromJson(Map<String, dynamic> json) =>
      _$ErrorDescriptorFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDescriptorToJson(this);

  @override
  int get status => HttpStatus.internalServerError;
}
