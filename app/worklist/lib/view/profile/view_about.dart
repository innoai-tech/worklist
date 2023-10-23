import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';
import 'package:syncer/syncer.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/domain/downloader/downloader.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/view/worklist/common.dart';

class ViewAbout implements QuickView {
  @override
  Widget get view => AboutCard();
}

class AboutCard extends SetupWidget {
  const AboutCard({super.key});

  @override
  setup(sc) {
    final registryStore = RegistryStore.context.use();
    final driver = Driver.context.use();
    final downloader = Downloader.context.use();

    final packageInfoRef = observableRef<PackageInfo?>(null);
    final currentVersionRef = ref<Version?>(null);
    final checkedVersionRef = observableRef<Version?>(null);
    final taskRef = ref<Task?>(null);
    final packageManifestRef = ref<ImageManifest?>(null);
    final progressPercentageRef = ref<double?>(null);

    final ticker = BehaviorSubject.seeded(0);

    ticker.stream
        .asyncMap((event) async => await PackageInfo.fromPlatform())
        .doOnData((info) {
      if (info.buildNumber == info.version) {
        packageInfoRef.value = PackageInfo(
          appName: info.appName,
          packageName: info.packageName,
          version: info.version,
          buildNumber: "0",
        );
        return;
      }
      packageInfoRef.value = info;
    }).listenOnMountedUntilUnmounted();

    packageInfoRef.stream.doOnData((info) {
      if (info != null) {
        currentVersionRef.value = Version.from(
          version: info.version,
          buildNumber: info.buildNumber,
        );
      }
    }).listenOnMountedUntilUnmounted();

    final getDefaultRepositoryRemote = () {
      final registry = registryStore.defaultRegistry;
      if (registry != null) {
        return Repository(name: "worklist/app")
            .remote(registryStore.clientProvider(sc.context, registry.key));
      }
      return null;
    };

    final localRepo = Repository(name: "worklist/app").local(driver);

    final listTags = FutureSubject.of((v) async {
      return await getDefaultRepositoryRemote()?.tags().all() ??
          List<String>.of([]);
    });

    listTags.success.doOnData((tags) {
      final lastVersion = Version.parseAndGetLatest(tags);

      if (lastVersion != null && currentVersionRef.value != null) {
        if (lastVersion > currentVersionRef.value!) {
          checkedVersionRef.value = lastVersion;
        } else {
          checkedVersionRef.value = currentVersionRef.value;
        }
      }
    }).listenOnMountedUntilUnmounted();

    final startTask = (Task task, {required ImageManifest manifest}) {
      packageManifestRef.value = manifest;
      taskRef.value = task;
      downloader.add(task);
      progressPercentageRef.value = 0;
    };

    checkedVersionRef.stream
        .whereType<Version>()
        .where((version) => version != currentVersionRef.value)
        .asyncMap((version) async {
      final remoteRepo = getDefaultRepositoryRemote();

      if (remoteRepo != null) {
        final im = await remoteRepo.resolveVersionedPackage(
          version: version,
          platform: Platform.local,
        );

        if (im != null) {
          startTask(
            im.asTask(
              src: remoteRepo,
              dest: localRepo,
              tag: "latest",
            ),
            manifest: im,
          );
        }
      }
    }).listenOnMountedUntilUnmounted();

    final startInstall = () async {
      await packageManifestRef.value
          ?.let((im) => im.layers?.firstOrNull)
          ?.let((d) async {
        final p =
            join((driver as FsDriver).root.path, d.digest!.asBlobFilePath());

        await OpenFile.open(
          p,
          type: d.mediaType!,
        );
      });
    };

    downloader.stream.doOnData((event) {
      taskRef.value?.let((task) {
        final percentage = task.progress.percentage;
        if (task.completed) {
          progressPercentageRef.value = null;
          startInstall();
          return;
        }
        progressPercentageRef.value = percentage;
      });
    }).listenUntilUnmounted();

    final checkUpdate = () {
      listTags.request(null);
    };

    return () {
      return Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outlined),
              title: Text(
                '关于',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text(packageInfoRef.value?.packageName ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    children: [
                      Text(currentVersionRef.value?.toString() ?? ""),
                      Text("on ${Platform.local}"),
                    ],
                  ),
                ],
              ),
              dense: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (currentVersionRef.value != null &&
                        checkedVersionRef.value == currentVersionRef.value)
                    ? TextButton(
                        onPressed: null,
                        child: Text("已经是最新版本"),
                      )
                    : TextButton(
                        onPressed: registryStore.defaultRegistry
                            ?.let((r) => () => checkUpdate()),
                        child: Text("更新"),
                      ),
                const SizedBox(width: 8),
              ],
            ),
            ...?progressPercentageRef.value?.let(
              (progressPercentage) => [
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                ),
              ],
            )
          ],
        ),
      );
    };
  }
}

extension AppDistributionExt on RepositoryService {
  Future<ImageManifest?> resolveVersionedPackage({
    required Version version,
    required Platform platform,
  }) async {
    final m = await manifests().get(Tag(name: version.toString()));

    if (m is ImageIndex) {
      for (var sub in m.manifests!) {
        if (sub.platform == platform) {
          return await manifests().get(sub.digest!) as ImageManifest;
        }
      }
    }

    return null;
  }
}
