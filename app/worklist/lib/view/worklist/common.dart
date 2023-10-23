import 'package:crpe/crpe.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storage/storage.dart';
import 'package:syncer/syncer.dart';
import 'package:worklistapp/common/ext.dart';

extension DescriptorExt on Descriptor {
  Task asTask({
    required RepositoryService src,
    required RepositoryService dest,
    required String topic,
  }) {
    return Task.of(
      (context) async {
        try {
          await dest.blobs().stat(digest!);
        } catch (err) {
          if (!(err is ErrBlobUnknown)) {
            rethrow;
          }

          final destWriter = await dest.blobs().create();

          final sourceReader = await src.blobs().open(digest!);
          await sourceReader
              .doOnData((buf) => context.addTransformed(buf.length))
              .pipe(destWriter.sink);

          await destWriter.commit(Descriptor(digest: digest));
        }
      },
      size: size!,
      id: "${topic}/${digest}",
    );
  }
}

extension ImageIndexExt on ImageIndex {
  Task asTask({
    required RepositoryService src,
    required RepositoryService dest,
    String? tag,
  }) {
    return Task.parallel(
      [
        ...?manifests?.let((manifests) => manifests.map((manifest) {
              return manifest.asTask(
                src: src,
                dest: dest,
                topic: "manifest",
              );
            })),
        Task.of(
          (context) async {
            final d = await src.manifests().put(digest, this);

            context.addTransformed(raw.length);

            await tag?.let(
              (tag) async => await src.tags().tag(
                    tag,
                    Descriptor(
                      digest: d,
                    ),
                  ),
            );

            return;
          },
          size: raw.length,
          id: "index/${digest}",
        )
      ],
      id: digest.toString(),
    );
  }
}

extension ImageManifestExt on ImageManifest {
  Task asTask({
    required RepositoryService src,
    required RepositoryService dest,
    String? tag,
  }) {
    final blobsTasks = [
      ...?config?.let((config) => [
            config.asTask(
              src: src,
              dest: dest,
              topic: "config",
            )
          ]),
      ...?layers?.map((layer) => layer.asTask(
            src: src,
            dest: dest,
            topic: "layer",
          ))
    ];

    return Task.parallel(
      [
        // layers first
        Task.parallel(blobsTasks, id: "${digest.toString()}/layers"),
        // then manifest
        Task.of(
          (context) async {
            final d = await dest.manifests().put(digest, this);

            context.addTransformed(raw.length);

            await tag?.let(
              (tag) async => await dest.tags().tag(
                  tag,
                  Descriptor(
                    digest: d,
                  )),
            );

            return;
          },
          size: raw.length,
          id: "manifest/${digest}",
        )
      ],
      id: digest.toString(),
      maxParallels: 1,
    );
  }
}
