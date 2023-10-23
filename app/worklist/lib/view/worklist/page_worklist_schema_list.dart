import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/blob_store/blob_store.dart';
import 'package:storage/spec/spec.dart';
import 'package:syncer/syncer.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/common/persist.dart';
import 'package:worklistapp/common/src/validator/validator.dart';
import 'package:worklistapp/domain/downloader/downloader.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';

class PageWorklistSchemaList extends SetupWidget<PageWorklistSchemaList>
    implements NavigationPage {
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
    final worklistSchemaStore = worklistSchemaStoreContext.use();

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
                    return WorklistSchemaAdd();
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
    final registryContext = registryStoreContext.use();
    final driver = driverContext.use();

    final localResp = Repository(name: sc.widget.schema.name).local(driver);
    final remoteResp = Repository(name: sc.widget.schema.name).remote(
      registryContext.clientProvider(sc.context, sc.widget.schema.endpoint),
    );

    final fetchLocalManifest = FutureSubject.of(
      (String tag) => localResp.manifests().get(Tag(name: tag)),
    );

    final fecthRemoteManifest = FutureSubject.of((String tag) async {
      return await remoteResp.manifests().get(Tag(name: tag));
    });

    final offlineReadyRef = ref(false);

    final getTag = () => sc.widget.schema.version ?? "latest";

    final taskRef = ref<Task?>(null);
    final progressPercentageRef = ref<double?>(null);

    fetchLocalManifest.success.doOnData((d) {
      offlineReadyRef.value = true;
      progressPercentageRef.value = null;
    }).listenOnMountedUntilUnmounted();

    final downloader = downloaderContext.use();

    fecthRemoteManifest.success.doOnData((m) {
      if (m is ImageManifest) {
        final task = m.asDownloadTask(
          remote: remoteResp,
          local: localResp,
          tag: getTag(),
        );

        taskRef.value = task;
        downloader.add(task);
        progressPercentageRef.value = 0;
      }
    }).listenOnMountedUntilUnmounted();

    downloader.stream.doOnData((event) {
      taskRef.value?.let((task) {
        final percentage = task.progress.percentage;
        if (task.completed) {
          fetchLocalManifest.request(getTag());
          return;
        }
        progressPercentageRef.value = percentage;
      });
    }).listenUntilUnmounted();

    onMounted(() {
      fetchLocalManifest.request(getTag());
    });

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
                    leading: Icon(Icons.download),
                    title: Text("重新下载"),
                    onTap: () {
                      offlineReadyRef.value = false;
                      progressPercentageRef.value = 0;
                      fecthRemoteManifest.request(getTag());
                      Navigator.pop(sc.context);
                    },
                  )
                ],
              ),
            );
          });
    };

    return () {
      return ListTile(
          title: Text(sc.widget.schema.name),
          subtitle: Text(getTag()),
          onLongPress: showOptions,
          onTap: offlineReadyRef.value.let((ready) {
            if (ready) {
              return () {
                sc.widget.onTapCreate?.let(
                    (onTapCreate) => onTapCreate(sc.widget.schema.copyWith(
                          version: getTag(),
                        )));
              };
            }
          }),
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
                      child: offlineReadyRef.value
                          ? Icon(Icons.play_arrow)
                          : progressPercentageRef.value
                                  ?.let((progressPercentage) => Stack(
                                        children: [
                                          Positioned(
                                            child: Center(
                                                child: Icon(Icons
                                                    .downloading_outlined)),
                                          ),
                                          CircularProgressIndicator(
                                            value: progressPercentage / 100,
                                          )
                                        ],
                                      )) ??
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  fecthRemoteManifest.request(getTag());
                                },
                                tooltip: "下载模板",
                                icon: Icon(Icons.download_rounded),
                              ),
                    ),
                  ),
          ));
    };
  }
}

class WorklistSchemaDel extends SetupWidget<WorklistSchemaDel> {
  final WorklistSchema schema;

  const WorklistSchemaDel({
    required this.schema,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();

    return () {
      return AlertDialog(
        title: Text("删除模板"),
        content: Text("是否删除模板 ${sc.widget.schema.key}"),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(sc.context);
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              registryStore.del(sc.widget.schema.key);
              Navigator.pop(sc.context);
            },
          ),
        ],
      );
    };
  }
}

class WorklistSchemaAdd extends SetupWidget {
  const WorklistSchemaAdd({super.key});

  @override
  setup(sc) {
    final worklistSchemaStore = worklistSchemaStoreContext.use();
    final worklistSchema = ref<WorklistSchema?>(null);

    return () {
      if (worklistSchema.value != null) {
        return VersionedWorklistSchemaForm(
          schema: worklistSchema.value!,
          onSubmit: (versioned) {
            worklistSchema.value = versioned;
            worklistSchemaStore.put(versioned);
            Navigator.pop(sc.context);
          },
        );
      }

      return ScopedWorklistSchemaForm(
        onSubmit: (scoped) {
          worklistSchema.value = scoped;
        },
      );
    };
  }
}

class ScopedWorklistSchemaForm extends SetupWidget<ScopedWorklistSchemaForm> {
  final Function(WorklistSchema schema) onSubmit;

  const ScopedWorklistSchemaForm({
    required this.onSubmit,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();

    final formKey = GlobalKey<FormState>();
    final fieldEndpoint = TextEditingController();
    final fieldName = TextEditingController(text: "worklist/example");

    return () {
      return Scaffold(
        appBar: AppBar(
          title: const Text("关联模板"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Form(
            key: formKey,
            onChanged: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      FormField<String>(
                        validator: validateRequired(),
                        builder: (formFieldState) {
                          return TextField(
                            controller: fieldEndpoint,
                            decoration: InputDecoration(
                              label: Text("Endpoint"),
                              hintText: "请选择...",
                              suffixIcon: Icon(Icons.chevron_right),
                              errorText: formFieldState.errorText,
                            ),
                            readOnly: true,
                            onTap: () {
                              Navigator.push(
                                sc.context,
                                MaterialPageRoute(builder: (context) {
                                  return SelectOptions(
                                    title: Text("选择 Endpoint"),
                                    value: fieldEndpoint.text,
                                    onValueChanged: (value) {
                                      fieldEndpoint.text = value ?? "";
                                      formFieldState.setValue(
                                        fieldEndpoint.text,
                                      );
                                      Navigator.pop(sc.context);
                                    },
                                    options: [
                                      ...registryStore.stream.value.values.map(
                                        (e) => SelectOption(
                                          label: Text(e.endpoint),
                                          value: e.endpoint,
                                        ),
                                      )
                                    ],
                                  );
                                }),
                              );
                            },
                          );
                        },
                      ),
                      TextFormField(
                        controller: fieldName,
                        validator: validateRequired(),
                        decoration: InputDecoration(
                          label: Text("Name"),
                          hintText: "worklist/example",
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      sc.widget.onSubmit(WorklistSchema(
                        endpoint: fieldEndpoint.text,
                        name: fieldName.text,
                      ));
                    }
                  },
                  child: Text("查询版本"),
                )
              ],
            ),
          ),
        ),
      );
    };
  }
}

class VersionedWorklistSchemaForm
    extends SetupWidget<VersionedWorklistSchemaForm> {
  final WorklistSchema schema;
  final Function(WorklistSchema schema) onSubmit;

  const VersionedWorklistSchemaForm({
    required this.schema,
    required this.onSubmit,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();
    final schemaRef = ref(sc.widget.schema);

    final allTags$ = FutureSubject.of((inputs) async {
      final client =
          registryStore.clientProvider(sc.context, schemaRef.value.endpoint);

      return await Repository(name: schemaRef.value.name)
          .remote(client)
          .tags()
          .all();
    });

    onMounted(() {
      allTags$.request(null);
    });

    final versionsRef = ref(List<String>.of([]));

    allTags$.success.doOnData((versions) {
      versionsRef.value = versions;
    }).listenOnMountedUntilUnmounted();

    return () {
      return SelectOptions(
        title: Text("选择版本"),
        value: schemaRef.value.version,
        onValueChanged: (value) {
          sc.widget.onSubmit(schemaRef.value.copyWith(
            version: value,
          ));
        },
        options: [
          ...versionsRef.value.map((version) => SelectOption(
                label: Text(version),
                value: version,
              ))
        ],
      );
    };
  }
}

class SelectOptions<T> extends SetupWidget<SelectOptions<T>> {
  final Widget? title;
  final T? value;
  final Function(T? value)? onValueChanged;
  final List<SelectOption<T>> options;

  const SelectOptions({
    required this.options,
    this.value,
    this.onValueChanged,
    this.title,
  });

  @override
  setup(sc) {
    return () {
      return Scaffold(
        appBar: AppBar(
          title: sc.widget.title,
        ),
        body: ListView(
          children: [
            ...sc.widget.options.map((o) => ListTile(
                  title: o.label,
                  selected: o.value == value,
                  onTap: () {
                    sc.widget.onValueChanged?.let((onValueChanged) {
                      onValueChanged(o.value);
                    });
                  },
                ))
          ],
        ),
      );
    };
  }
}

class SelectOption<T> {
  final Widget label;
  final T value;

  const SelectOption({
    required this.label,
    required this.value,
  });
}

extension DescriptorExt on Descriptor {
  Task asDownloadTask({
    required RepositoryService remote,
    required RepositoryService local,
    required String topic,
  }) {
    return Task.of(
      (context) async {
        try {
          await local.blobs().stat(digest!);
        } catch (err) {
          if (!(err is ErrBlobUnknown)) {
            rethrow;
          }

          final w = await local.blobs().create();
          final source = await remote.blobs().open(digest!);

          await source
              .doOnData((buf) => context.addTransformed(buf.length))
              .pipe(w.sink);

          await w.commit(Descriptor(digest: digest));
        }
      },
      size: size!,
      id: "${topic}/${digest}",
    );
  }
}

extension ImageIndexExt on ImageIndex {
  Task asDownloadTask({
    required RepositoryService remote,
    required RepositoryService local,
    String? tag,
  }) {
    return Task.parallel(
      [
        ...?manifests?.let((manifests) => manifests.map((manifest) {
              return manifest.asDownloadTask(
                remote: remote,
                local: local,
                topic: "manifest",
              );
            })),
        Task.of(
          (context) async {
            final d = await local.manifests().put(digest, this);

            context.addTransformed(raw.length);

            await tag?.let(
              (tag) async => await local.tags().tag(
                  tag,
                  Descriptor(
                    digest: d,
                  )),
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
  Task asDownloadTask({
    required RepositoryService remote,
    required RepositoryService local,
    String? tag,
  }) {
    final blobsTasks = [
      ...?config?.let((config) => [
            config.asDownloadTask(
              remote: remote,
              local: local,
              topic: "config",
            )
          ]),
      ...?layers?.map((layer) => layer.asDownloadTask(
            remote: remote,
            local: local,
            topic: "layer",
          ))
    ];

    return Task.parallel(
      [
        ...blobsTasks,
        Task.of(
          (context) async {
            final d = await local.manifests().put(digest, this);

            context.addTransformed(raw.length);

            await tag?.let(
              (tag) async => await local.tags().tag(
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
    );
  }
}
