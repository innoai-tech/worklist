import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:storage/storage.dart';

// https://github.com/distribution/distribution/blob/main/registry/storage/linkedblobstore.go
class LinkedBlobStore implements BlobService {
  final BlobService blobStore;
  final Driver driver;
  final String linkPathPrefix;

  const LinkedBlobStore({
    required this.blobStore,
    required this.driver,
    required this.linkPathPrefix,
  });

  @override
  Future<Descriptor> stat(Digest digest) async {
    try {
      var dgst = await driver.readAsLinkedDigest(
        digest: digest,
        prefix: linkPathPrefix,
      );
      return blobStore.stat(dgst);
    } catch (err) {
      throw ErrBlobUnknown(digest: digest);
    }
  }

  @override
  Future<Stream<List<int>>> open(digest, {start, end}) async {
    var canonical = await stat(digest); // access check
    return blobStore.open(canonical.digest!, start: start, end: end);
  }

  @override
  Future<void> delete(digest) async {
    await driver.deleteLinkedDigest(
      digest: digest,
      prefix: linkPathPrefix,
    );
  }

  @override
  Future<BlobWriter> create() async {
    final bw = await blobStore.create();

    return _BlobWriter(
      blobWriter: bw,
      driver: driver,
      linkPathPrefix: linkPathPrefix,
    );
  }
}

class _BlobWriter implements BlobWriter {
  final BlobWriter blobWriter;

  final Driver driver;
  final String linkPathPrefix;

  _BlobWriter({
    required this.driver,
    required this.blobWriter,
    required this.linkPathPrefix,
  });

  @override
  Future<Descriptor> commit(Descriptor provisional) async {
    var d = await blobWriter.commit(provisional);
    await driver.writeAsLinkedDigest(digest: d.digest!, prefix: linkPathPrefix);
    return d;
  }

  @override
  Future<void> cancel() {
    return blobWriter.cancel();
  }

  @override
  Digest get digest => blobWriter.digest;

  @override
  int get size => blobWriter.size;

  @override
  StreamSink<List<int>> get sink => blobWriter.sink;
}

extension DriverExtForLinkedDigest on Driver {
  Future<void> writeAsLinkedDigest({
    required Digest digest,
    required String prefix,
  }) async {
    await writeAsString(
      linkedDigestPath(prefix: prefix, digest: digest),
      digest.toString(),
    );
  }

  Future<Digest> readAsLinkedDigest({
    required Digest digest,
    required String prefix,
  }) async {
    return Digest.parse(await readAsString(linkedDigestPath(
      prefix: prefix,
      digest: digest,
    )));
  }

  Future<void> deleteLinkedDigest({
    required Digest digest,
    required String prefix,
  }) async {
    await remove(linkedDigestPath(prefix: prefix, digest: digest));
  }
}

String linkedDigestPath({
  required String prefix,
  required Digest digest,
}) {
  return p.join(prefix, digest.alg, digest.hash, "link");
}
