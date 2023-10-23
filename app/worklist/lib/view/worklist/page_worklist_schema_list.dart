import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart' hide Form;
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';
import 'package:syncer/syncer.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/domain/downloader/downloader.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';
import 'package:worklistapp/view/worklist/common.dart';

import 'action/worklist_schema_add.dart';
import 'action/worklist_schema_del.dart';

class PageWorklistSchemaList extends SetupWidget implements NavigationPage {
  final Function(WorklistSchema schema)? onSelect;

  const PageWorklistSchemaList({
    super.key,
    this.onSelect,
  });

  @override
  NavigationDestination get destination => NavigationDestination(
        label: "模板管理",
        icon: Icon(Icons.storage_outlined),
        selectedIcon: Icon(Icons.storage_rounded),
      );

  @override
  setup(sc) {
    final worklistSchemaStore = WorklistSchemaStore.context.use();

    return () {
      return Scaffold(
        appBar: AppBar(
          title: Text(destination.label),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  sc.context,
                  MaterialPageRoute(builder: (context) {
                    return WorklistSchemaAdd(onAdded: () {
                      Navigator.pop(context);
                    });
                  }),
                );
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: worklistSchemaStore.stream.buildOnData((worklistSchemas) {
          return ListView(
            children: [
              ...worklistSchemas.values.map(
                (schema) => WorklistSchemaTileWithState(
                  schema: schema,
                  onTapCreate: onSelect,
                ),
              )
            ],
          );
        }),
      );
    };
  }
}

class WorklistSchemaTileWithState
    extends SetupWidget<WorklistSchemaTileWithState> {
  final WorklistSchema schema;
  final Function(WorklistSchema schema)? onTapCreate;

  const WorklistSchemaTileWithState({
    required this.schema,
    this.onTapCreate,
    super.key,
  });

  @override
  setup(sc) {
    final registryContext = RegistryStore.context.use();
    final worklistSchemaStore = WorklistSchemaStore.context.use();
    final driver = Driver.context.use();

    final localRepo = Repository(name: sc.widget.schema.name).local(driver);
    final remoteRepo = Repository(name: sc.widget.schema.name).remote(
      registryContext.clientProvider(sc.context, sc.widget.schema.endpoint),
    );

    final fetchLocalManifest = FutureSubject.of(
      (String tag) => localRepo.manifests().get(Tag(name: tag)),
    );

    final fetchRemoteManifest = FutureSubject.of((String tag) async {
      return await remoteRepo.manifests().get(Tag(name: tag));
    });

    final downloader = Downloader.context.use();
    final getTag = () => sc.widget.schema.version ?? "latest";

    final remoteManifestRef = ref<ImageManifest?>(null);
    final localManifestRef = ref<ImageManifest?>(null);
    final progressPercentageRef = ref<double?>(null);
    final taskRef = observableRef<Task?>(null);

    fetchLocalManifest.success.doOnData((m) {
      localManifestRef.value = m as ImageManifest;

      // ugly sync the description to worklist list
      worklistSchemaStore.put(sc.widget.schema.copyWith(
        digest: m.digest,
        description: m.annotations?["worklist.displayName"],
      ));
    }).listenOnMountedUntilUnmounted();

    fetchRemoteManifest.success.doOnData((m) {
      if (m is ImageManifest) {
        remoteManifestRef.value = m;
      }
    }).listenOnMountedUntilUnmounted();

    final startSync = () {
      remoteManifestRef.value?.let((m) {
        progressPercentageRef.value = 0;
        localManifestRef.value = null;

        taskRef.value = m.asTask(
          src: remoteRepo,
          dest: localRepo,
          tag: getTag(),
        );
      });
    };

    taskRef.stream.whereType<Task>().doOnData((task) {
      downloader.add(task);
      progressPercentageRef.value = 0;
    }).listenOnMountedUntilUnmounted();

    downloader.stream.doOnData((event) {
      taskRef.value?.let((task) {
        final percentage = task.progress.percentage;
        if (task.completed) {
          fetchLocalManifest.request(getTag());
          progressPercentageRef.value = null;
          return;
        }
        progressPercentageRef.value = percentage;
      });
    }).listenUntilUnmounted();

    onMounted(() {
      fetchLocalManifest.request(getTag());
      fetchRemoteManifest.request(getTag());
    });

    final hasUpgrade = () {
      if (remoteManifestRef.value == null) {
        return false;
      }
      return remoteManifestRef.value?.digest != localManifestRef.value?.digest;
    };

    final offlineReady = () {
      return localManifestRef.value != null;
    };

    final showOptions = () {
      showModalBottomSheet(
          context: sc.context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("移除"),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return WorklistSchemaDel(schema: sc.widget.schema);
                          });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.download),
                    title: hasUpgrade() ? Text("下载") : Text("重新下载"),
                    onTap: () {
                      startSync();
                      Navigator.pop(sc.context);
                    },
                  ),
                  ...?offlineReady().ifTrue(() {
                    return [
                      ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text("开始清单"),
                        onTap: () {
                          sc.widget.onTapCreate?.let(
                              (onTapCreate) => onTapCreate(sc.widget.schema));

                          Navigator.pop(sc.context);
                        },
                      ),
                    ];
                  }),
                  Divider(color: Colors.transparent)
                ],
              ),
            );
          });
    };

    return () {
      return ListTile(
          title: Text(sc.widget.schema.displayName),
          subtitle: Text(getTag()),
          onTap: showOptions,
          trailing: fetchLocalManifest.requesting.buildOnData(
            (requesting) => requesting
                ? SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: progressPercentageRef.value
                              ?.let((progressPercentage) => Stack(
                                    children: [
                                      Positioned(
                                        child: Center(
                                            child: Icon(
                                          Icons.downloading_outlined,
                                        )),
                                      ),
                                      CircularProgressIndicator(
                                        value: progressPercentage / 100,
                                      )
                                    ],
                                  )) ??
                          Badge(
                            label: hasUpgrade().ifTrue(() => Text("待更新")),
                            alignment: Alignment.center,
                            isLabelVisible: hasUpgrade(),
                            child: Icon(Icons.more_horiz),
                          ),
                    )),
          ));
    };
  }
}
