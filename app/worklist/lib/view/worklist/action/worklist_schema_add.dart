import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart' hide Form;
import 'package:formkit/formkit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';

class WorklistSchemaAdd extends SetupWidget {
  final Function? onAdded;

  const WorklistSchemaAdd({
    super.key,
    this.onAdded,
  });

  @override
  setup(sc) {
    final worklistSchemaStore = WorklistSchemaStore.context.use();

    return () {
      return ScopedWorklistSchemaForm(
        onSubmit: (scoped) {
          showModalBottomSheet(
            context: sc.context,
            showDragHandle: true,
            builder: (ctx) {
              return SafeArea(
                child: VersionedWorklistSchemaForm(
                  schema: scoped,
                  onSubmit: (versioned) {
                    // close bottom sheet
                    Navigator.pop(ctx);

                    worklistSchemaStore.put(versioned);

                    onAdded?.let((onAdded) => onAdded());
                  },
                ),
              );
            },
          );
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
    final registryStore = RegistryStore.context.use();

    final initialValues = {
      "endpoint": registryStore.defaultRegistry?.key,
      "name": "worklist/example",
    };

    final formSchema = Schema.object({
      "endpoint": Schema.string()
          .described(label: "Endpoint")
          .inputBy(Selector(options: [
            ...registryStore.stream.value.values.map(
              (e) => Option(
                label: e.endpoint,
                value: e.endpoint,
              ),
            )
          ])),
      "name": Schema.string().described(label: "Name").inputBy(TextInput()),
    });

    return () {
      return Scaffold(
        appBar: AppBar(
          title: const Text("关联模板"),
        ),
        body: Form(
          schema: formSchema,
          initialValues: initialValues,
          builder: (ctx, formState, fields) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: fields,
                    ),
                  ),
                  SafeArea(
                    child: FilledButton(
                      onPressed: () {
                        if (formState.validate()) {
                          sc.widget.onSubmit(
                              WorklistSchema.fromJson(formState.values()));
                        }
                      },
                      child: Text("选择版本"),
                    ),
                  )
                ],
              ),
            );
          },
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
    final registryStore = RegistryStore.context.use();
    final schemaRef = ref(sc.widget.schema);

    final fetchAllTags = FutureSubject.of((inputs) async {
      final client =
          registryStore.clientProvider(sc.context, schemaRef.value.endpoint);

      return await Repository(name: schemaRef.value.name)
          .remote(client)
          .tags()
          .all();
    });

    onMounted(() {
      fetchAllTags.request(null);
    });

    final versionsRef = ref(List<String>.of([]));

    fetchAllTags.success.doOnData((versions) {
      versionsRef.value = versions;
    }).listenOnMountedUntilUnmounted();

    fetchAllTags.error.doOnData((err) {
      ScaffoldMessenger.of(sc.context).showSnackBar(SnackBar(
        content: Text('${err}'),
      ));
    }).listenOnMountedUntilUnmounted();

    return () {
      return fetchAllTags.requesting.buildOnData((requesting) {
        return requesting.ifTrue(() => Center(
                  child: CircularProgressIndicator(),
                )) ??
            ListView(
              children: [
                ...versionsRef.value.map((version) => ListTile(
                      title: Text(version),
                      onTap: () {
                        sc.widget.onSubmit(schemaRef.value.copyWith(
                          version: version,
                        ));
                      },
                    ))
              ],
            );
      });
    };
  }
}
