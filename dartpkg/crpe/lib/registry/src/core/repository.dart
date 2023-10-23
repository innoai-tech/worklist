import 'package:storage/storage.dart';

class Repository {
  final String name;

  const Repository({
    required this.name,
  });

  static Future<Manifest> push({
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

        await repository.manifests().put(m.digest, m);

        return m;
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

        await repository.manifests().put(m.digest, m);

        if (tags != null) {
          for (final tag in tags) {
            await repository.manifests().put(Tag(name: tag), m);
          }
        }

        return m;
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
}

abstract class ManifestService {
  Future<bool> exists(Reference reference);

  Future<Manifest> get(Reference reference);

  Future<void> delete(Reference reference);

  Future<Digest> put(Reference reference, Manifest manifest);
}

abstract class TagService {
  Future<List<String>> all();

  Future<List<String>> lookup(Descriptor descriptor);

  Future<Descriptor> get(String tag);

  Future<void> tag(String tag, Descriptor descriptor);

  Future<void> untag(String tag);
}
