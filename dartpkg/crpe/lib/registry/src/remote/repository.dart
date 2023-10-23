import 'dart:async';

import 'package:crpe/registry/remote.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storage/storage.dart';

import '../core/repository.dart';

extension RemoteRepositoryRepositoryProvider on Repository {
  RepositoryService remote(ClientProvider clientProvider) {
    return _Repository(
      clientProvider: clientProvider,
      name: name,
    );
  }
}

class _Repository implements RepositoryService {
  final ClientProvider clientProvider;
  final String name;

  _Repository({
    required this.clientProvider,
    required this.name,
  });

  @override
  ManifestService manifests() {
    return _ManifestService(
      clientProvider: clientProvider,
      name: name,
    );
  }

  @override
  BlobService blobs() {
    return _BlobService(
      clientProvider: clientProvider,
      name: name,
    );
  }

  @override
  TagService tags() {
    return _TagService(
      clientProvider: clientProvider,
      name: name,
    );
  }
}

var acceptedManifests = [
  ImageIndex.type,
  ImageManifest.type,
];

class _ManifestService implements ManifestService {
  final ClientProvider clientProvider;
  final String name;

  _ManifestService({
    required this.clientProvider,
    required this.name,
  });

  @override
  Future<bool> exists(digestOrTag) async {
    try {
      await clientProvider.client.fetch(
        Request.uri(
          "/v2/$name/manifests/$digestOrTag",
          method: "HEAD",
          headers: {
            "accept": acceptedManifests,
          },
        ),
      );
      return true;
    } catch (err) {
      return false;
    }
  }

  @override
  Future<void> delete(reference) async {
    await clientProvider.client.fetch(
      Request.uri(
        "/v2/$name/manifests/${reference.ref}",
        method: "DELETE",
      ),
    );
  }

  @override
  Future<Manifest> get(reference) async {
    final resp = await clientProvider.client.fetch(
      Request.uri("/v2/$name/manifests/${reference.ref}",
          method: "GET",
          headers: {
            "accept": acceptedManifests,
          }),
    );
    return Manifest.fromJson(await resp.json());
  }

  @override
  Future<Digest> put(reference, manifest) async {
    final resp = await clientProvider.client.fetch(
      Request.uri(
        "/v2/$name/manifests/${reference.ref}",
        method: "PUT",
      ).copyWith(
        headers: {
          "Content-Type": manifest.mediaType,
        },
        requestBody: Stream.fromIterable([manifest.raw]),
      ),
    );

    try {
      return Digest.parse(resp.headers["docker-content-digest"]?.first ?? "");
    } catch (e) {}
    return manifest.digest;
  }
}

class _BlobService implements BlobService {
  final ClientProvider clientProvider;
  final String name;

  _BlobService({
    required this.clientProvider,
    required this.name,
  });

  @override
  Future<void> delete(Digest digest) async {
    await clientProvider.client.fetch(
      Request.uri(
        "/v2/$name/blobs/$digest",
        method: "DELETE",
      ),
    );
  }

  @override
  Future<Descriptor> stat(Digest digest) async {
    try {
      final resp = await clientProvider.client.fetch(
        Request.uri(
          "/v2/$name/blobs/$digest",
          method: "HEAD",
        ),
      );
      return Descriptor(
        mediaType: resp.headers["Content-Type"]?.first,
        digest: digest,
      );
    } catch (err) {
      if (err is ResponseException) {
        if (err.statusCode == HttpStatus.notFound) {
          throw ErrBlobUnknown(digest: digest);
        }
      }
      rethrow;
    }
  }

  @override
  Future<Stream<List<int>>> open(Digest digest, {int? start, int? end}) async {
    try {
      final resp = await clientProvider.client.fetch(
        Request.uri(
          "/v2/$name/blobs/$digest",
          method: "GET",
          headers: (start != null || end != null)
              ? {"Range": "bytes=${start ?? 0}-${end ?? ""}"}
              : null,
        ),
      );
      return resp.responseBody;
    } catch (err) {
      if (err is ResponseException) {
        if (err.statusCode == HttpStatus.notFound) {
          throw ErrBlobUnknown(digest: digest);
        }
      }
      rethrow;
    }
  }

  @override
  Future<BlobWriter> create() async {
    final resp = await clientProvider.client.fetch(
      Request.uri(
        "/v2/$name/blobs/uploads/",
        method: "POST",
      ),
    );

    return _BlobWriter(
      clientProvider: clientProvider,
      name: name,
      location: (resp.headers["location"]?.first)!,
    );
  }
}

class _BlobWriter implements BlobWriter {
  final ClientProvider clientProvider;
  final String name;

  late String location;

  _BlobWriter({
    required this.clientProvider,
    required this.name,
    required this.location,
  });

  @override
  Future<void> cancel() async {
    await _sink?.close();
  }

  @override
  Future<Descriptor> commit(Descriptor provisional) async {
    if (provisional.digest != null &&
        provisional.digest.toString() != digest.toString()) {
      throw ErrDigestNotMatch(
        expected: provisional.digest!,
        got: digest,
      );
    }

    await clientProvider.client.fetch(
      Request.uri(location, method: "PUT", queryParameters: {
        "digest": digest,
      }),
    );

    return provisional.copyWith(
      digest: digest,
      size: size,
    );
  }

  Digest? _digest;
  int? _size;

  Digest get digest {
    if (_digest == null) {
      throw Exception("don't use digest before write");
    }
    return _digest!;
  }

  @override
  int get size {
    if (_size == null) {
      throw Exception("don't use digest before write");
    }
    return _size!;
  }

  StreamSink<List<int>>? _sink;
  StreamSubscription? _sub;

  StreamSink<List<int>> get sink {
    if (_sink != null) {
      return _sink!;
    }

    final b$ = BehaviorSubject<List<int>>();

    final cleanup = () async {
      await _sub?.cancel();
      _sink = null;
      _sub = null;
    };

    _sub = MergeStream([
      b$.asyncMap((buf) async {
        final resp = await clientProvider.client.fetch(
          Request.uri(location, method: "PATCH").copyWith(
            headers: {
              "Content-Type": "application/octet-stream",
              "Content-Range": "${_size ?? 0}-${(_size ?? 0) + buf.length}",
              "Content-Length": buf.length,
            },
            requestBody: Stream.fromIterable([buf]),
          ),
        );

        // location changed if provided
        location = (resp.headers["location"]?.first) ?? location;

        return buf;
      }).doOnData((buf) {
        _size = (_size ?? 0) + buf.length;
      }),
      b$.transform(Digest.sha256Transformer()).doOnData((digest) {
        _digest = digest;
      }),
    ]).listen(
      (_) {},
      onDone: () async {
        await cleanup();
      },
    );

    return _sink ??= b$;
  }
}

class _TagService implements TagService {
  final ClientProvider clientProvider;
  final String name;

  _TagService({
    required this.clientProvider,
    required this.name,
  });

  @override
  Future<List<String>> all() async {
    final resp = await clientProvider.client.fetch(
      Request.uri(
        "/v2/$name/tags/list",
        method: "GET",
      ),
    );

    final data = await resp.json();

    return (data["tags"] as List<dynamic>).cast<String>();
  }

  @override
  Future<Descriptor> get(String tag) async {
    final resp = await clientProvider.client.fetch(
      Request.uri("/v2/$name/manifests/$tag", method: "GET", headers: {
        "accept": acceptedManifests,
      }),
    );

    final data = await resp.json();

    return Descriptor.fromJson(data).copyWith(
      digest: Digest.parse(
        resp.headers["docker-content-digest"]?.firstOrNull ?? "",
      ),
    );
  }

  @override
  Future<void> tag(String tag, Descriptor descriptor) async {
    final ms = _ManifestService(clientProvider: clientProvider, name: name);
    await ms.put(Tag(name: tag), await ms.get(descriptor.digest!));
    return;
  }

  @override
  Future<void> untag(String tag) {
    throw Exception("unsupported");
  }
}
