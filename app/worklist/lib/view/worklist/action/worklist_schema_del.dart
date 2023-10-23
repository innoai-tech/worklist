import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';

class WorklistSchemaDel extends SetupWidget<WorklistSchemaDel> {
  final WorklistSchema schema;

  const WorklistSchemaDel({
    required this.schema,
    super.key,
  });

  @override
  setup(sc) {
    final registryStore = RegistryStore.context.use();

    return () {
      return AlertDialog(
        title: Text("删除模板"),
        content: Text("是否删除模板 ${sc.widget.schema.key}"),
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
              registryStore.del(sc.widget.schema.key);
              Navigator.pop(sc.context);
            },
          ),
        ],
      );
    };
  }
}
