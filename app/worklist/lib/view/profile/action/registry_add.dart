import 'package:flutter/material.dart' hide Form;
import 'package:formkit/formkit.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/domain/registry/registry.dart';

class RegistryAdd extends SetupWidget {
  const RegistryAdd({super.key});

  @override
  setup(sc) {
    final registryStore = RegistryStore.context.use();

    final initialValues = {
      "endpoint": "https://harbor.innoai.tech",
    };

    final formSchema = Schema.object({
      "endpoint": Schema.string()
          .described(label: "Endpoint", hint: "请输入 https://<hostname>")
          .inputBy(TextInput(format: "url")),
    });

    return () {
      return Scaffold(
          appBar: AppBar(
            title: const Text("配置仓库"),
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
                              final values = formState.values();
                              registryStore.put(Registry.fromJson(values));
                              Navigator.pop(sc.context);
                            }
                          },
                          child: Text("保存"),
                        ),
                      )
                    ],
                  ),
                );
              }));
    };
  }
}
