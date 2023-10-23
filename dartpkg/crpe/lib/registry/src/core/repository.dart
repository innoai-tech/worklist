import 'dart:convert';

import 'package:storage/storage.dart';

class Repository {
  final String name;

  const Repository({
    required this.name,
  });

  static Future<Manifest> resolveLayers({
    required Manifest manifest,
    required RepositoryService repository,
  }) async {
    switch (manifest) {
      case (ImageIndex index):
        List<Descriptor> manifests = [];

        for (var sub in index.manifests ?? []) {
          final m = await resolveLayers(
            manifest: sub,
            repository: repository,
          );

          manifests.add(
            Descriptor(
              digest: m.digest,
              size: m.raw.length,
              stream: Stream.fromIterable([m.raw]),
            ),
          );
        }

        return manifest.copyWith(
          manifests: manifests,
        );
      case (ImageManifest manifest):
        List<Descriptor> layers = [];

        final b = repository.blobs();

        for (var layer in (manifest.layers ?? [] as List<Descriptor>)) {
          layers.add(layer.copyWith(
            stream: await b.open(layer.digest!),
          ));
        }

        print(jsonEncode(manifest));

        return manifest.copyWith(
          config: manifest.config!.copyWith(
            stream: await b.open(manifest.config!.digest!),
          ),
          layers: layers,
        );
      default:
        throw new Exception("unsupported manifest ${manifest.mediaType}");
    }
  }

  static Future<Digest> push({
    required Manifest manifest,
    required RepositoryService repository,
    List<String>? tags,
  }) async {
    switch (manifest) {
      case (ImageIndex index):
        List<Descriptor> manifests = [];

        for (var sub in index.manifests ?? []) {
          manifests.add(await ingest(
            descriptor: sub,
            repository: repository,
          ));
        }

        var m = manifest.copyWith(
          manifests: manifests,
        );

        return await repository.manifests().put(m.digest, m);
      case (ImageManifest manifest):
        Descriptor? config;
        List<Descriptor> layers = [];

        if (manifest.config != null) {
          config = await ingest(
            descriptor: manifest.config!,
            repository: repository,
          );
        }

        for (var layer in manifest.layers ?? []) {
          layers.add(await ingest(
            descriptor: layer,
            repository: repository,
          ));
        }

        var m = manifest.copyWith(
          config: config,
          layers: layers,
        );

        final d = await repository.manifests().put(m.digest, m);

        if (tags != null) {
          for (final tag in tags) {
            await repository.manifests().put(Tag(name: tag), m);
          }
        }

        return d;
      default:
        throw new Exception("unsupported manifest ${manifest.mediaType}");
    }
  }

  static Future<Descriptor> ingest({
    required Descriptor descriptor,
    required RepositoryService repository,
  }) async {
    if (descriptor.digest != null) {
      try {
        await repository.blobs().stat(descriptor.digest!);
        return descriptor;
      } catch (err) {
        if (!(err is ErrBlobUnknown)) {
          rethrow;
        }
      }
    }

    if (descriptor.stream != null) {
      var w = await repository.blobs().create();
      await descriptor.stream!.pipe(w.sink);
      return await w.commit(descriptor);
    }

    return descriptor;
  }
}

abstract class RepositoryService {
  BlobService blobs();

  ManifestService manifests();

  TagService tags();
}

abstract class ManifestService {
  Future<bool> exists(Reference reference);

  Future<Manifest> get(Reference reference);

  Future<void> delete(Reference reference);

  Future<Digest> put(Reference reference, Manifest manifest);
}

abstract class TagService {
  Future<List<String>> all();

  Future<Descriptor> get(String tag);

  Future<void> tag(String tag, Descriptor descriptor);

  Future<void> untag(String tag);
}
