import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/ext.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/domain/registry/registry.dart';

import 'action/registry_add.dart';
import 'action/registry_del.dart';

class ViewRegistry implements QuickView {
  @override
  Widget get view => RegistryCard();
}

class RegistryCard extends SetupWidget {
  const RegistryCard({super.key});

  @override
  setup(sc) {
    final registryStore = RegistryStore.context.use();

    final addNewRegistry = () {
      Navigator.push(
        sc.context,
        MaterialPageRoute(builder: (context) {
          return RegistryAdd();
        }),
      );
    };

    final removeRegistry = (Registry registry) {
      showDialog(
        context: sc.context,
        builder: (context) {
          return RegistryDel(registry: registry);
        },
      );
    };

    final setDefault = (Registry registry) {
      registryStore.setDefault(registry);
    };

    return () {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.source_outlined),
              title: Text(
                '仓库',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            registryStore.stream.buildOnData((registries) {
              return Column(
                children: [
                  ...registries.values.map((registry) => ListTile(
                        title: Text(registry.endpoint),
                        selected: registry.isDefault ?? false,
                        onTap: () => setDefault(registry),
                        onLongPress: registry.isDefault
                            ?.ifFalse(() => () => removeRegistry(registry)),
                      ))
                ],
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    addNewRegistry();
                  },
                  child: Text("添加"),
                ),
                const SizedBox(width: 8),
              ],
            )
          ],
        ),
      );
    };
  }
}
