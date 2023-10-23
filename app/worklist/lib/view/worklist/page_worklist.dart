import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';
import 'package:syncer/syncer.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/domain/downloader/downloader.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';
import 'package:worklistapp/view/worklist/page_worklist_schema_list.dart';

import 'action/worklist_del.dart';
import 'common.dart';
import 'page_worklist_form.dart';

class PageWorklist extends SetupWidget implements NavigationPage {
  const PageWorklist({super.key});

  @override
  get destination => const NavigationDestination(
        icon: Icon(Icons.view_list_outlined),
        selectedIcon: Icon(Icons.view_list_rounded),
        label: "工作清单",
      );

  @override
  setup(sc) {
    final worklistStore = WorklistStore.context.use();

    return () {
      return Scaffold(
        appBar: AppBar(
          title: Text("工作清单"),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                sc.context,
                MaterialPageRoute(
                    builder: (c) => PageWorklistSchemaList(
                          onSelect: (schema) {
                            worklistStore.put(Worklist.fromSchema(schema));
                            Navigator.pop(sc.context);
                          },
                        )),
              );
            },
            icon: Icon(Icons.tag),
          ),
        ),
        body: worklistStore.stream.buildOnData((worklists) {
          return ListView(
            children: [
              ...worklists.values.map((worklist) {
                return _WorkListItem(worklist: worklist);
              })
            ],
          );
        }),
      );
    };
  }
}

class _WorkListItem extends SetupWidget<_WorkListItem> {
  final Worklist worklist;

  const _WorkListItem({
    required this.worklist,
    super.key,
  });

  @override
  setup(sc) {
    final worklistSchemaStore = WorklistSchemaStore.context.use();
    final worklistStore = WorklistStore.context.use();
    final registryContext = RegistryStore.context.use();
    final driver = Driver.context.use();

    final downloader = Downloader.context.use();
    final taskRef = ref<Task?>(null);
    final progressPercentageRef = ref<double?>(null);

    final pushToRemote = (Worklist worklist) async {
      final digest = worklist.digest;

      if (digest == null) {
        return null;
      }

      final client = registryContext.clientProvider(
        sc.context,
        worklist.schema.endpoint,
      );

      final r = registryContext.get(worklist.schema.endpoint);

      final remoteRepo = Repository(
        name: "${r?.username ?? "anonymous"}/${worklist.schema.name}",
      ).remote(client);

      final userLocalRepo =
          Repository(name: "local/${worklist.schema.name}").local(driver);

      final manifest =
          (await userLocalRepo.manifests().get(digest) as ImageManifest);

      final task = manifest.asTask(
        src: userLocalRepo,
        dest: remoteRepo,
        // FIXME
        tag: "latest",
      );

      taskRef.value = task;
      downloader.add(task);
      progressPercentageRef.value = 0;
    };

    downloader.stream.doOnData((event) {
      taskRef.value?.let((task) {
        final percentage = task.progress.percentage;
        if (task.completed) {
          worklistStore.put(worklist.copyWith(latestSynced: worklist.digest));
          taskRef.value = null;
          progressPercentageRef.value = null;
          return;
        }
        progressPercentageRef.value = percentage;
      });
    }).listenUntilUnmounted();

    final showOptionsFor = (Worklist worklist) {
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
                    leading: Icon(Icons.download),
                    title: Text("删除清单"),
                    onTap: () {
                      Navigator.pop(sc.context);

                      showDialog(
                        context: sc.context,
                        builder: (context) {
                          return WorklistDel(worklist: worklist);
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cloud_upload_rounded),
                    // enabled: worklist.syncable,
                    title: Text("上传清单"),
                    onTap: () {
                      Navigator.pop(sc.context);

                      pushToRemote(worklist);
                    },
                  ),
                  Divider(color: Colors.transparent)
                ],
              ),
            );
          });
    };

    return () {
      final worklist = worklistSchemaStore.get(sc.widget.worklist.schema.key);

      return ListTile(
        title: Text(
          sc.widget.worklist.name,
          style: TextStyle(overflow: TextOverflow.ellipsis),
        ),
        subtitle: Text(
          worklist?.displayName ?? "",
          style: TextStyle(overflow: TextOverflow.ellipsis),
        ),
        trailing: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child:
                progressPercentageRef.value?.let((progressPercentage) => Stack(
                          children: [
                            Positioned(
                              child: Center(
                                child: Icon(Icons.upload_outlined),
                              ),
                            ),
                            CircularProgressIndicator(
                              value: progressPercentage / 100,
                            )
                          ],
                        )) ??
                    sc.widget.worklist.synced.ifTrue(() {
                      return Icon(Icons.verified);
                    }) ??
                    sc.widget.worklist.syncable.ifTrue(() {
                      return Icon(Icons.cloud_upload_rounded);
                    }) ??
                    Icon(Icons.draw),
          ),
        ),
        onLongPress: () {
          showOptionsFor(sc.widget.worklist);
        },
        onTap: () => {
          Navigator.push(
            sc.context,
            MaterialPageRoute(
              builder: (context) => PageWorklistForm(
                worklist: sc.widget.worklist,
              ),
            ),
          )
        },
      );
    };
  }
}
