import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import './worklist_schema.dart';

var worklistSchemaStoreContext =
    Context<WorklistSchemaStore>.create(() => WorklistSchemaStore.seeded({}));

class WorklistSchemaStore extends CommonStore<Map<String, WorklistSchema>> {
  factory WorklistSchemaStore.seeded(Map<String, WorklistSchema> value) {
    final subject = BehaviorSubject<Map<String, WorklistSchema>>.seeded(value);

    return WorklistSchemaStore(stream: subject, sink: subject);
  }

  const WorklistSchemaStore({
    required super.stream,
    required super.sink,
  });

  static Map<String, WorklistSchema> valueFromJson(
      Map<String, dynamic> values) {
    return values
        .map((key, value) => MapEntry(key, WorklistSchema.fromJson(value)));
  }

  get name => "worklist_schema";

  put(WorklistSchema worklist) {
    sink.add({
      ...stream.value,
      worklist.key: worklist,
    });
  }

  del(String key) {
    sink.add({
      ...(stream.value..removeWhere((k, v) => k == key)),
    });
  }
}
