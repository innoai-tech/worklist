import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:storage/errcode/errcode.dart';
import 'package:storage/spec/spec.dart';

part '__generated__/errcode.g.dart';

@JsonSerializable()
class ErrBlobUnknown implements StatusError {
  final Digest digest;
  final String? path;

  const ErrBlobUnknown({
    required this.digest,
    this.path,
  });

  @override
  int get status => HttpStatus.notFound;

  @override
  String get code => "BLOB_UNKNOWN";

  @override
  String toString() => "blob unknown ${digest}";

  @override
  Map<String, dynamic>? toJson() => _$ErrBlobUnknownToJson(this);
}

@JsonSerializable()
class ErrDigestNotMatch implements StatusError {
  final Digest expected;
  final Digest got;

  const ErrDigestNotMatch({
    required this.expected,
    required this.got,
  });

  @override
  int get status => HttpStatus.badRequest;

  @override
  String get code => "DIGEST_NOT_MATCH";

  @override
  String toString() => "Digest did not match";

  @override
  Map<String, dynamic>? toJson() => _$ErrDigestNotMatchToJson(this);
}
