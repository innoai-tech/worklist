// https://github.com/opencontainers/image-spec/blob/main/specs-go/v1/descriptor.goith_extension/copy_with_extension.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'reference.dart';

part '__generated__/descriptor.g.dart';

@JsonSerializable(includeIfNull: false)
@CopyWith(skipFields: true)
class Descriptor {
  final String? mediaType;
  final Map<String, String>? annotations;
  final Platform? platform;

  final Digest? digest;
  final int? size;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Stream<List<int>>? stream;

  const Descriptor({
    this.mediaType,
    this.digest,
    this.size,
    this.annotations,
    this.platform,
    this.stream,
  });

  factory Descriptor.fromStream({
    required String mediaType,
    required Stream<List<int>> stream,
  }) {
    return Descriptor(mediaType: mediaType, stream: stream);
  }

  factory Descriptor.fromBytes({
    required String mediaType,
    required List<int> data,
  }) {
    return Descriptor(
      mediaType: mediaType,
      stream: Stream.fromIterable([data]),
    );
  }

  factory Descriptor.fromJson(Map<String, dynamic> json) =>
      _$DescriptorFromJson(json);

  Map<String, dynamic> toJson() => _$DescriptorToJson(this);
}

@JsonSerializable()
class Platform {
  final String architecture;
  final String os;
  final String? variant;
  final List<String>? features;
  @JsonKey(name: "os.version")
  final String? osVersion;
  @JsonKey(name: "os.features")
  final List<String>? osFeatures;

  const Platform({
    required this.os,
    required this.architecture,
    this.variant,
    this.features,
    this.osVersion,
    this.osFeatures,
  });

  factory Platform.fromJson(Map<String, dynamic> json) =>
      _$PlatformFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformToJson(this);

  String normalize() {
    return [
      normalizeOS(os),
      ...normalizeArch(architecture, variant ?? ""),
    ].join("/");
  }

  static String normalizeOS(String os) {
    os = os.toLowerCase();

    switch (os) {
      case "macos":
        return "darwin";
    }

    return os;
  }

  static List<String> normalizeArch(String arch, String variant) {
    arch = arch.toLowerCase();
    variant = variant.toLowerCase();

    switch (arch) {
      case "i386":
        arch = "386";
        variant = "";
        break;
      case "x86_64":
      case "x86-64":
        arch = "amd64";
        variant = "";
        break;
      case "aarch64":
      case "arm64":
        arch = "arm64";
        switch (variant) {
          case "8":
          case "v8":
            variant = "";
        }
        break;
      case "armhf":
        arch = "arm";
        variant = "v7";
        break;
      case "armel":
        arch = "arm";
        variant = "v6";
        break;
      case "arm":
        switch (variant) {
          case "":
          case "7":
            variant = "v7";
            break;
          case "5":
          case "6":
          case "8":
            variant = "v$variant";
            break;
        }
    }

    if (variant == "") {
      return [arch];
    }

    return [arch, variant];
  }
}
