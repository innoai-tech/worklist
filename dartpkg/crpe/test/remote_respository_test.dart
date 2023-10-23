import 'dart:convert';
import 'dart:io' as io;

import 'package:crpe/crpe.dart';
import 'package:crpe/registry/remote.dart';
import 'package:crpe/registry/src/remote/repository.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripper.dart' show HttpStatus, Request;
import 'package:storage/spec/spec.dart';
import 'package:test/test.dart';

void main() {
  var logger = Logger(StdLogSink("roundtripper"));

  group("RemoteRepository", () {
    final rr = ClientProvider(
      endpoint: "https://${io.Platform.environment["CONTAINER_REGISTRY"]}",
      username: io.Platform.environment["CONTAINER_REGISTRY_USERNAME"],
      password: io.Platform.environment["CONTAINER_REGISTRY_PASSWORD"],
    );

    final repo = Repository(name: "worklist/example").remote(rr);

    test("/v2/", () async {
      final resp = await rr.client.fetch(Request.uri("/v2/"));
      expect(resp.statusCode, equals(HttpStatus.ok));
    });

    var ctx = Logger.withLogger(logger);

    test("push && pull", () async {
      await ctx.run(() async {
        var c = Descriptor.fromBytes(
          mediaType: MediaType.ConfigTypeV1,
          data: utf8.encode("""
{
  "type": "object",
  "properties": {
    "projectID": {
      "type": "string",
      "field": {
        "label": "项目名称"
      }
    },
    "address": {
      "type": "string",
      "field": {
        "label": "勘探地点"
      }
    }
  }
}
"""),
        );

        var m = await Repository.push(
          manifest: ImageManifest(
            artifactType: ArtifactType.Schema,
            config: c,
            layers: [
              Descriptor.fromBytes(
                mediaType: "text/plain",
                data: utf8.encode(
                  List<String>.generate(100, (index) => "1").join(""),
                ),
              )
            ],
          ),
          repository: repo,
          tags: ["latest", "test"],
        );

        final foundManifest = await repo.manifests().get(Tag(name: "test"));
        expect(foundManifest.raw, equals(m.raw));
      });
    });
  });
}
