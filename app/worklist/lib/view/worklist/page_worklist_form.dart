import 'dart:convert';
import 'dart:io';

import 'package:crpe/crpe.dart';
import 'package:flutter/material.dart' hide Form;
import 'package:formkit/formkit.dart';
import 'package:logr/logr.dart';
import 'package:mime/mime.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';

class PageWorklistForm extends SetupWidget<PageWorklistForm>
    implements NavigationPage {
  final Worklist worklist;

  const PageWorklistForm({
    required this.worklist,
    super.key,
  });

  @override
  get destination => const NavigationDestination(
        icon: Icon(Icons.document_scanner_outlined),
        selectedIcon: Icon(Icons.document_scanner_rounded),
        label: "清单",
      );

  @override
  setup(sc) {
    final worklistSchemaStore = WorklistSchemaStore.context.use();
    final worklistStore = WorklistStore.context.use();

    final driver = Driver.context.use();
    final localRepo =
        Repository(name: sc.widget.worklist.schema.name).local(driver);
    final userLocalRepo =
        Repository(name: "local/${sc.widget.worklist.schema.name}")
            .local(driver);

    final submittedValuesRef = observableRef<Map<String, dynamic>?>(null);

    submittedValuesRef.stream.whereNotNull().asyncMap((values) async {
      worklistStore.put(sc.widget.worklist.copyWith(
        validValues: values,
      ));

      final d = await userLocalRepo.ingest(
        values,
        worklist: sc.widget.worklist,
      );

      worklistStore.put(sc.widget.worklist.copyWith(
        validValues: values,
        digest: d,
      ));

      Navigator.of(sc.context).pop();

      return;
    }).listenOnMountedUntilUnmounted();

    final schemaRef = ref<Schema?>(null);

    final loadConfig = FutureSubject.of(
      (ImageManifest m) async {
        Logger.current?.info(
          "loading worklist schema from digest: ${m.config!.digest!} of ${m.digest}",
        );

        final raw = await localRepo.blobs().get(m.config!.digest!);
        final json = jsonDecode(Utf8Codec().decode(raw));

        return Schema.fromJson(json);
      },
    );

    final getTag = () {
      return worklistSchemaStore.get(sc.widget.worklist.schema.key)?.version ??
          "latest";
    };

    final getDigest = () {
      return worklistSchemaStore.get(sc.widget.worklist.schema.key)?.digest ??
          "latest";
    };

    final loadManifest = FutureSubject.of(
      (inputs) async => await localRepo.manifests().get(Tag(name: getTag())),
    );

    loadConfig.success.doOnData((formSchema) {
      schemaRef.value = formSchema;
    }).listenOnMountedUntilUnmounted();

    loadManifest.success.doOnData((m) {
      if (m is ImageManifest && m.artifactType == ArtifactType.Schema) {
        loadConfig.request(m);
      }
    }).listenOnMountedUntilUnmounted();

    onMounted(() {
      loadManifest.request(null);
    });

    return () {
      return schemaRef.value != null
          ? Form(
              schema: schemaRef.value!,
              initialValues: sc.widget.worklist.initialValues,
              onChanged: (values) {
                worklistStore.put(sc.widget.worklist
                    .copyWith(
                      latestValues: values,
                    )
                    .copyWithNull(validValues: true, digest: true));
              },
              builder: (ctx, state, fields) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("${sc.widget.worklist.schema.name}"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (state.validate()) {
                            submittedValuesRef.value = state.values();
                          }
                        },
                        icon: Icon(Icons.save),
                      )
                    ],
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: fields,
                      ),
                    ),
                  ),
                );
              })
          : Scaffold(
              appBar: AppBar(
                title: Text("${sc.widget.worklist.schema.name}"),
              ),
              body: Center(
                child: Text("-"),
              ),
            );
    };
  }
}

extension RepositoryServiceCommitExt on RepositoryService {
  Future<Digest> ingest(Map<String, dynamic> values,
      {required Worklist worklist}) async {
    Map<Digest, Descriptor> layers = {};

    final formValues = await replaceWith(values, (value, keyPath) async {
      if (value is String && value.startsWith("file://")) {
        final filename = Uri.parse(value).path;
        final file = File(filename);

        final d = await Repository.ingest(
          descriptor: Descriptor(
            mediaType: lookupMimeType(filename),
            stream: file.openRead(),
          ),
          repository: this,
        );

        layers[d.digest!] = d;

        return BlobURI(
          mediaType: d.mediaType!,
          digest: d.digest!,
        ).toString();
      }

      return value;
    });

    final d = await Repository.push(
        repository: this,
        manifest: ImageManifest(
          artifactType: ArtifactType.FormData,
          config: Descriptor.fromBytes(
            mediaType: ManifestType.FormData,
            data: Utf8Codec().encode(jsonEncode(formValues)),
          ).copyWith(annotations: {
            "worklist.schema.name": "${worklist.schema.name}",
            "worklist.schema.ref": "${worklist.schema.version ?? "latest"}",
          }),
          layers: [
            ...layers.values,
          ],
        ),
        tags: [worklist.id]);

    return d;
  }
}
