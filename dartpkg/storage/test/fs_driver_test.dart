import 'dart:io';

import 'package:storage/driver/driver.dart';
import 'package:test/test.dart';

void main() {
  group("Driver", () {
    final driver = FsDriver(root: Directory(".turbo/driver_test"));

    setUpAll(() async {
      // ensure root exists
      await driver.mkdir(".", recursive: true);
      await driver.stat(".");
    });

    tearDownAll(() async {
      await driver.remove(".");
    });

    test("mkdir", () async {
      await driver.mkdir("a");
      final info = await driver.stat("a");
      expect(info.name, equals("a"));
      expect(info.isDir, equals(true));
    });

    test("create file", () async {
      await driver.writeAsString("a/x.txt", "test");
      final info = await driver.stat("a/x.txt");
      expect(info.name, equals("x.txt"));

      final contents = await driver.readAsString("a/x.txt");
      expect(contents, equals("test"));

      final list =
          await driver.list("a").then((list) => list.map((e) => e.name));
      expect(list, equals(["x.txt"]));
    });
  });
}
