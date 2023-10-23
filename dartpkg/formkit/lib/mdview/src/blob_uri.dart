import 'package:storage/spec/spec.dart';

class BlobURI {
  factory BlobURI.parse(String uri) {
    if (!uri.startsWith("blob:")) {
      throw FormatException("invalid blob URI ${uri}");
    }

    uri = uri.substring("blob:".length);

    final i = uri.indexOf(",");
    if (i < 0) {
      throw FormatException("invalid blob URI ${uri}");
    }

    final typ = uri.substring(0, i);
    final hash = uri.substring(i + 1);
    final parts = typ.split(";");

    final mediaTypeAndModifier = parts.first.split("+");

    return BlobURI(
      mediaType: mediaTypeAndModifier.first,
      digest: Digest(
        alg: parts.lastOrNull ?? "sha256",
        hash: hash,
      ),
      compressType: mediaTypeAndModifier.lastOrNull,
    );
  }

  final String mediaType;
  final Digest digest;
  final String? compressType;

  BlobURI({
    required this.mediaType,
    required this.digest,
    this.compressType,
  });

  @override
  String toString() {
    return "blob:${mediaType}${compressType != "" ? "+${compressType}" : ""};${digest.alg},${digest.hash}";
  }
}
