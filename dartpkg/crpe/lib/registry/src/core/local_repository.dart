import 'dart:convert';

import 'package:crpe/crpe.dart';
import 'package:path/path.dart' as p;
import 'package:storage/storage.dart';

import 'linked_blob_store.dart';

extension LocalRepositoryRepositoryProvider on Repository {
  RepositoryService local(Driver driver) {
    return _RepositoryService(
      driver: driver,
      name: name,
    );
  }
}

class _RepositoryService implements RepositoryService {
  final Driver driver;
  final String name;

  _RepositoryService({
    required this.driver,
    required this.name,
  });

  BlobService? _blobService;

  BlobService get blobStore {
    return _blobService ?? (_blobService = driver.asBlobService());
  }

  String dir(String part) {
    return p.join("repositories", name, part);
  }

  @override
  BlobService blobs() => LinkedBlobStore(
        blobStore: blobStore,
        driver: driver,
        linkPathPrefix: dir("_layers"),
      );

  @override
  ManifestService manifests() {
    return _ManifestService(
      name: name,
      driver: driver,
      blobService: LinkedBlobStore(
        blobStore: blobStore,
        driver: driver,
        linkPathPrefix: dir("_manifests/revisions"),
      ),
    );
  }

  @override
  TagService tags() {
    return _ManifestService(
      name: name,
      driver: driver,
      blobService: LinkedBlobStore(
        blobStore: blobStore,
        driver: driver,
        linkPathPrefix: dir("_manifests/revisions"),
      ),
    ).tagService;
  }
}

class _ManifestService implements ManifestService {
  final BlobService blobService;
  final Driver driver;
  final String name;

  _ManifestService({
    required this.blobService,
    required this.driver,
    required this.name,
  });

  TagService? _tagService;

  TagService get tagService => _tagService ??= _TagStore(
        driver: driver,
        blobStatter: blobService,
        name: name,
      );

  @override
  Future<bool> exists(reference) async {
    switch (reference) {
      case (Digest digest):
        try {
          await blobService.stat(digest);
          return true;
        } catch (e) {
          return false;
        }
      case (Tag tag):
        await tagService.get(tag.name);
        return true;
      default:
        return false;
    }
  }

  @override
  Future<void> delete(reference) async {
    switch (reference) {
      case (Digest digest):
        await blobService.delete(digest);
      case (Tag tag):
        await tagService.untag(tag.name);
    }
  }

  @override
  Future<Digest> put(reference, manifest) async {
    switch (reference) {
      case (Digest digest):
        await blobService.put(manifest.mediaType, manifest.raw);
        return digest;
      case (Tag tag):
        await tagService.tag(tag.name, Descriptor(digest: manifest.digest));
        return manifest.digest;
      default:
        throw Exception("unknown reference ${reference}");
    }
  }

  @override
  Future<Manifest> get(reference) async {
    switch (reference) {
      case (Digest digest):
        try {
          var raw = await blobService.get(digest);
          return Manifest.fromJson(jsonDecode(utf8.decode(raw)));
        } catch (e) {
          throw ErrManifestUnknownRevision(
            name: name,
            revision: digest.toString(),
          );
        }
      case (Tag tag):
        final d = await tagService.get(tag.name);
        return await get(d.digest!);
      default:
        throw Exception("unknown reference ${reference}");
    }
  }
}

class _TagStore implements TagService {
  final BlobStatter blobStatter;
  final Driver driver;
  final String name;

  const _TagStore({
    required this.driver,
    required this.blobStatter,
    required this.name,
  });

  @override
  Future<List<String>> all() async {
    return await driver.list(tagPath()).then(
          (list) => list.map((info) => info.name).toList(),
        );
  }

  @override
  Future<Descriptor> get(String tag) async {
    final d = Digest.parse(
      await driver.readAsString(tagCurrentLink(tag)),
    );

    return await blobStatter.stat(d);
  }

  @override
  Future<void> tag(tag, desc) async {
    // Link into the index
    await driver.writeAsLinkedDigest(
      digest: desc.digest!,
      prefix: tagEntryIndex(tag),
    );

    // Overwrite the current link
    return await driver.writeAsString(
        tagCurrentLink(tag), desc.digest.toString());
  }

  @override
  Future<void> untag(String tag) async {
    final path = tagPath(tag: tag);
    await driver.remove(path);
  }

  // https://github.com/distribution/distribution/blob/main/registry/storage/paths.go#L26
  String tagPath({String? tag}) {
    if (tag != null) {
      return p.join("repositories", name, "_manifests/tags", tag);
    }
    return p.join("repositories", name, "_manifests/tags");
  }

  String tagCurrentLink(String tag) {
    return p.join(tagPath(tag: tag), "current", "link");
  }

  String tagEntryIndex(String tag) {
    return p.join(tagPath(tag: tag), "index");
  }
}
