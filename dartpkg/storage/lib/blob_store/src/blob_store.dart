import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:storage/driver/driver.dart';
import 'package:storage/spec/spec.dart';
import 'package:uuid/uuid.dart';

import 'blob_service.dart';
import 'errcode.dart';

extension BlobServiceOfDriver on Driver {
  BlobService asBlobService() {
    return _BlobStore(this);
  }
}

class _BlobStore implements BlobService {
  final Driver driver;

  _BlobStore(this.driver);

  @override
  Future<void> delete(Digest digest) async {
    await driver.remove(digest.asBlobFilePath(), recursive: true);
    return;
  }

  @override
  Future<Descriptor> stat(Digest digest) async {
    try {
      var fi = await driver.stat(digest.asBlobFilePath());

      return Descriptor(
        mediaType: "application/octet-stream",
        digest: digest,
        size: fi.size,
      );
    } catch (err) {
      if (err is ErrNotExist) {
        throw ErrBlobUnknown(digest: digest);
      }
      rethrow;
    }
  }

  @override
  Future<Stream<List<int>>> open(Digest digest, {int? start, int? end}) async {
    await stat(digest);

    return await driver
        .openFile(digest.asBlobFilePath())
        .then((f) => f.openRead(
              start: start,
              end: end,
            ));
  }

  @override
  Future<BlobWriter> create() async {
    final filename = "ingests/${Uuid().v4()}";

    return _BlobWriter(
      file: await driver.openFile(filename, createIsNotExists: true),
      filename: filename,
      driver: driver,
      blobStatter: this,
    );
  }
}

class _BlobWriter extends BlobWriter {
  final String filename;
  final FileInterface file;
  final Driver driver;
  final BlobStatter blobStatter;

  _BlobWriter({
    required this.filename,
    required this.file,
    required this.driver,
    required this.blobStatter,
  });

  @override
  Future<void> cancel() async {
    await _sink?.close();
    await driver.remove(filename);
  }

  @override
  Future<Descriptor> commit(Descriptor provisional) async {
    await _sink?.close();

    try {
      final d = await blobStatter.stat(digest);
      await driver.remove(filename);
      return provisional.copyWith(
        digest: d.digest,
        size: d.size,
      );
    } catch (e) {
      if (e is ErrBlobUnknown) {
        if (provisional.digest != null &&
            provisional.digest.toString() != digest.toString()) {
          throw ErrDigestNotMatch(
            expected: provisional.digest!,
            got: digest,
          );
        }

        var dest = digest.asBlobFilePath();

        await driver.mkdir(p.dirname(dest), recursive: true);
        await driver.rename(filename, dest);

        return provisional.copyWith(
          digest: digest,
          size: size,
        );
      }
      rethrow;
    }
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

    StreamSink<List<int>>? file$;

    final cleanup = () async {
      await _sub?.cancel();
      await file$?.close();
      _sink = null;
      _sub = null;
    };

    _sub = MergeStream([
      b$.asyncMap((buf) async {
        file$ ??= await file.openWrite();
        return buf;
      }).doOnData((buf) {
        file$?.add(buf);
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

extension BlobFilePath on Digest {
  String asBlobFilePath() {
    return p.join(
      "blobs",
      alg,
      hash,
      "data",
    );
  }
}
