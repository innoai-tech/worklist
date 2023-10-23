import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';

class WorklistDel extends SetupWidget<WorklistDel> {
  final Worklist worklist;

  const WorklistDel({
    required this.worklist,
    super.key,
  });

  @override
  setup(sc) {
    final store = WorklistStore.context.use();

    return () {
      return AlertDialog(
        title: Text("删除清单"),
        content: Text("是否删除清单 ${sc.widget.worklist.id}"),
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
              store.del(sc.widget.worklist.id);

              Navigator.pop(sc.context);
            },
          ),
        ],
      );
    };
  }
}
