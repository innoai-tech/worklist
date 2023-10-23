import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract class Reference {
  String get ref;
}

class Tag implements Reference {
  final String name;

  const Tag({
    required this.name,
  });

  @override
  String get ref => name;
}

class Digest implements Reference {
  factory Digest.fromString(String str) {
    return Digest.fromBytes(const Utf8Codec().encode(str));
  }

  factory Digest.fromBytes(List<int> bytes) {
    return Digest(
      hash: sha256.convert(bytes).toString(),
    );
  }

  static StreamTransformer<List<int>, Digest> sha256Transformer() {
    return StreamTransformer.fromBind(
      (input$) => input$.transform(sha256).transform(
            StreamTransformer.fromHandlers(
              handleData: (h, s) => s.add(
                Digest(hash: h.toString()),
              ),
            ),
          ),
    );
  }

  factory Digest.parse(String digest) {
    var parts = digest.split(":");
    if (parts.length != 2) {
      throw Exception("invalid digest: digest");
    }
    return Digest(alg: parts.first, hash: parts.last);
  }

  final String alg;
  final String hash;

  const Digest({
    required this.hash,
    this.alg = "sha256",
  });

  @override
  String get ref => toString();

  @override
  String toString() {
    return "$alg:$hash";
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    return other is Digest && other.hashCode == hashCode;
  }

  factory Digest.fromJson(String digest) => Digest.parse(digest);

  String toJson() {
    return toString();
  }
}
