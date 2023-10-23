import 'dart:convert';
import 'dart:io';

import 'package:crpe/crpe.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

void main() {
  group("Repository", () {
    final driver = FsDriver(root: Directory(".turbo/registry_test"));

    final repo = Repository(name: "worklist/example").local(driver);

    setUpAll(() async {
      await driver.remove(".");
    });

    test("push && pull", () async {
      var c = Descriptor.fromBytes(
        mediaType: "application/vnd.worklist.config.v1+json",
        data: utf8.encode("""
{
  "properties": {
    "projectID": {
      "type": "string",
      "metadata": {
        "label": "项目名称"
      }
    },
    "address": {
      "type": "string",
      "metadata": {
        "label": "勘探地点"
      }
    }
  }
}
"""),
      );

      var m = await Repository.push(
        manifest: ImageManifest(
          artifactType: "application/vnd.worklist.schema+type",
          config: c,
          layers: [
            Descriptor.fromBytes(
              mediaType: "text/plain",
              data: utf8.encode("txt"),
            )
          ],
        ),
        repository: repo,
        tags: ["latest", "main"],
      );

      final foundManifest = await repo.manifests().get(Tag(name: "latest"));
      expect(foundManifest.raw, equals(m.raw));
    });
  });
}
