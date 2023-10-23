import 'dart:convert';
import 'dart:io';

import 'package:storage/storage.dart';
import 'package:test/test.dart';

void main() {
  group("Storage", () {
    final driver = FsDriver(root: Directory(".turbo/storage_test"));
    final store = driver.asBlobService();

    const text = "中文123abc";
    final dgst = Digest.fromString(text);

    setUpAll(() async {
      await driver.remove(".");

      // ensure root exists
      await driver.mkdir(".", recursive: true);
      await driver.stat(".");
    });

    // tearDownAll(() async {
    //   await driver.remove(".");
    // });

    test('ingest', () async {
      final w = await store.create();
      await Stream.fromIterable([Utf8Codec().encode(text).cast<int>()])
          .pipe(w.sink);
      final d = await w.commit(Descriptor(mediaType: "text/plain"));
      expect(d.size, equals(12));
      expect(d.digest, equals(dgst));
    });

    test('provider', () async {
      final data = await store.get(dgst);
      expect(const Utf8Codec().decode(data), text);
    });
  });
}
