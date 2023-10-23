import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:storage/errcode/errcode.dart';

part '__generated__/errcode.g.dart';

@JsonSerializable()
class ErrTagUnknown implements StatusError {
  final String tag;
  final String name;

  const ErrTagUnknown({
    required this.tag,
    required this.name,
  });

  @override
  int get status => HttpStatus.notFound;

  @override
  String get code => "TAG_UNKNOWN";

  @override
  String toString() => "tag unknown";

  @override
  Map<String, dynamic>? toJson() => _$ErrTagUnknownToJson(this);
}

@JsonSerializable()
class ErrManifestUnknownRevision implements StatusError {
  final String revision;
  final String name;

  const ErrManifestUnknownRevision({
    required this.revision,
    required this.name,
  });

  @override
  int get status => HttpStatus.notFound;

  @override
  String get code => "MANIFEST_INVALID";

  @override
  String toString() => "unverified manifest, name=${name} revision=$revision";

  @override
  Map<String, dynamic>? toJson() => _$ErrManifestUnknownRevisionToJson(this);
}
