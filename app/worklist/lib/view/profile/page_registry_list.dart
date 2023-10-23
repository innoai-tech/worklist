import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/common/validator.dart';
import 'package:worklistapp/domain/registry/registry.dart';

class PageRegistryList extends SetupWidget implements NavigationPage {
  const PageRegistryList({super.key});

  @override
  NavigationDestination get destination => NavigationDestination(
        label: "仓库管理",
        icon: Icon(Icons.storage_outlined),
        selectedIcon: Icon(Icons.storage_rounded),
      );

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();

    return () {
      return Scaffold(
        appBar: AppBar(
          title: const Text("仓库管理"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  sc.context,
                  MaterialPageRoute(builder: (context) {
                    return RegistryAdd();
                  }),
                );
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: registryStore.stream.buildOnData((registries) {
          return ListView(
            children: [
              ...registries.values.map((registry) => ListTile(
                    title: Text(Uri.parse(registry.endpoint).host),
                    subtitle: Text(registry.endpoint),
                    onLongPress: () {
                      showDialog(
                        context: sc.context,
                        builder: (context) {
                          return RegistryDel(registry: registry);
                        },
                      );
                    },
                  ))
            ],
          );
        }),
      );
    };
  }
}

class RegistryDel extends SetupWidget {
  final Registry registry;

  const RegistryDel({
    required this.registry,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();

    return () {
      return AlertDialog(
        title: Text("删除仓库"),
        content: Text("是否删除仓库 ${registry.endpoint}"),
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
              registryStore.del(registry.endpoint);

              Navigator.pop(sc.context);
            },
          ),
        ],
      );
    };
  }
}

class RegistryAdd extends SetupWidget {
  const RegistryAdd({super.key});

  @override
  setup(sc) {
    final registryStore = registryStoreContext.use();

    final formKey = GlobalKey<FormState>();

    final fieldEndpoint = TextEditingController(
      text: "https://harbor.innoai.tech",
    );

    return () {
      return Scaffold(
          appBar: AppBar(
            title: const Text("配置仓库"),
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
                    child: TextFormField(
                      controller: fieldEndpoint,
                      validator: compose([
                        validateRequired(),
                        validateFormatURL(),
                      ]),
                      decoration: InputDecoration(
                        label: Text("Endpoint"),
                        helperText: "请输入 https://<hostname>",
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        registryStore.put(
                          Registry.fromURI(
                            Uri.parse(fieldEndpoint.text.trim()),
                          ),
                        );
                        Navigator.pop(sc.context);
                      }
                    },
                    child: Text("保存"),
                  )
                ],
              ),
            ),
          ));
    };
  }
}
