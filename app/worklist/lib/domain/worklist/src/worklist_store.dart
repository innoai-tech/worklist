import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'worklist.dart';

class WorklistStore extends CommonStore<Map<String, Worklist>> {
  static final context =
      Context<WorklistStore>.create(() => WorklistStore.seeded({}));

  factory WorklistStore.seeded(Map<String, Worklist> value) {
    final subject = BehaviorSubject<Map<String, Worklist>>.seeded(value);

    return WorklistStore(stream: subject, sink: subject);
  }

  const WorklistStore({
    required super.stream,
    required super.sink,
  });

  static Map<String, Worklist> valueFromJson(Map<String, dynamic> values) {
    return values.map((key, value) => MapEntry(key, Worklist.fromJson(value)));
  }

  get name => "worklist";

  put(Worklist worklist) {
    sink.add({
      ...stream.value,
      worklist.id: worklist,
    });
  }

  del(String key) {
    sink.add({
      ...(stream.value..removeWhere((k, v) => k == key)),
    });
  }
}
