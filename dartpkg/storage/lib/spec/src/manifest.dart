// https://github.com/opencontainers/image-spec/blob/main/specs-go/v1/manifest.go

import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'descriptor.dart';
import 'reference.dart';

part '__generated__/manifest.g.dart';

abstract class Manifest {
  String get mediaType;

  String? get artifactType;

  Map<String, dynamic> toJson();

  List<int> get raw;

  Digest get digest;

  factory Manifest.fromJson(Map<String, dynamic> json) {
    switch (json["mediaType"]) {
      case ImageIndex.type:
        return ImageIndex.fromJson(json);
      case ImageManifest.type:
        return ImageManifest.fromJson(json);
      default:
        throw Exception("unsupported");
    }
  }
}

@CopyWith(skipFields: true, copyWithNull: true)
@JsonSerializable(includeIfNull: false)
class ImageManifest implements Manifest {
  // https://github.com/opencontainers/image-spec/blob/main/manifest.md

  static const type = "application/vnd.oci.image.manifest.v1+json";

  final String mediaType;
  final int schemaVersion;

  final Descriptor? config;
  final List<Descriptor>? layers;
  final Map<String, String>? annotations;
  final String? artifactType;

  ImageManifest({
    this.schemaVersion = 2,
    this.mediaType = ImageManifest.type,
    this.artifactType,
    this.config,
    this.layers,
    this.annotations,
  });

  factory ImageManifest.fromJson(Map<String, dynamic> json) =>
      _$ImageManifestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageManifestToJson(this);

  List<int>? _raw;

  @override
  List<int> get raw {
    return _raw ??= utf8.encode(jsonEncode(toJson()));
  }

  Digest? _digest;

  @override
  Digest get digest {
    return _digest ??= Digest.fromBytes(raw);
  }
}

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true, copyWithNull: true)
class ImageIndex implements Manifest {
  // https://github.com/opencontainers/image-spec/blob/main/image-index.md
  static const type = "application/vnd.oci.image.index.v1+json";

  final String mediaType;
  final int schemaVersion;

  final String? artifactType;
  final List<Descriptor>? manifests;
  final Map<String, String>? annotations;

  ImageIndex({
    this.schemaVersion = 2,
    this.mediaType = ImageIndex.type,
    this.artifactType,
    this.manifests,
    this.annotations,
  });

  factory ImageIndex.fromJson(Map<String, dynamic> json) =>
      _$ImageIndexFromJson(json);

  Map<String, dynamic> toJson() => _$ImageIndexToJson(this);

  List<int>? _raw;

  @override
  List<int> get raw {
    return _raw ??= utf8.encode(jsonEncode(toJson()));
  }

  Digest? _digest;

  @override
  Digest get digest {
    return _digest ??= Digest.fromBytes(raw);
  }
}
