import 'dart:async';

import 'package:storage/driver/driver.dart';
import 'package:storage/spec/spec.dart';

abstract class BlobStatter {
  Future<Descriptor> stat(Digest digest);
}

abstract class BlobIngester {
  Future<BlobWriter> create();
}

abstract class BlobDeleter {
  Future<void> delete(Digest digest);
}

abstract class BlobProvider {
  Future<Stream<List<int>>> open(Digest digest, {int? start, int? end});
}

extension BlobIngesterExt on BlobIngester {
  Future<Descriptor> put(String mediaType, List<int> data) async {
    final w = await create();
    w.sink.add(data);
    return await w.commit(Descriptor(mediaType: mediaType));
  }
}

extension BlobProviderExt on BlobProvider {
  Future<List<int>> get(Digest digest) async {
    return await open(digest).then((s) => s.readAsBytes());
  }
}

abstract class BlobService
    implements BlobStatter, BlobProvider, BlobIngester, BlobDeleter {}

abstract class BlobWriter {
  int get size;

  Digest get digest;

  Future<Descriptor> commit(Descriptor provisional);

  StreamSink<List<int>> get sink;

  Future<void> cancel();
}
