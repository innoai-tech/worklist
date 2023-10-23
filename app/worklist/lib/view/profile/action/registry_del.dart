import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/domain/registry/registry.dart';

class RegistryDel extends SetupWidget {
  final Registry registry;

  const RegistryDel({
    required this.registry,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = RegistryStore.context.use();

    return () {
      return AlertDialog(
        title: Text("删除仓库"),
        content: Text("是否删除仓库 ${registry.endpoint}"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
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
