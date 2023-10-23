import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group("util", () {
    test("set / get", () {
      final values = Map<String, dynamic>.from({});
      set(values, KeyPath.from(["a", 1, "c"]), "-");
      expect(values, equals(values));
      expect(get(values, KeyPath.from(["a", 1, "c"])), equals("-"));
      expect(get(values, KeyPath.from(["a", 0, "c"])), equals(null));
      expect(get(values, KeyPath.from(["c"])), equals(null));
      expect(get(values, KeyPath.from([1])), equals(null));
    });

    test("patch / get", () {
      final values = Map<String, dynamic>.from({});

      final patched = patch(values, KeyPath.from(["a", 1, "c"]), "-");
      expect(patched != values, equals(true));
      expect(get(patched, KeyPath.from(["a", 1, "c"])), equals("-"));

      final patchedWithoutChanges =
          patch(patched, KeyPath.from(["a", 1, "c"]), "-");

      expect(patchedWithoutChanges, equals(patched));

      final patchedAgain =
          patch(patchedWithoutChanges, KeyPath.from(["a", 2, "c"]), "-");
      expect(patchedAgain != patchedWithoutChanges, equals(true));
    });
  });

  group("SchemaType", () {
    final schema = ObjectType(
      properties: {
        "name": Schema.string().described(label: "名称"),
        "desc": Schema.string().described(label: "描述"),
        "envType": Schema.ref("EnvType").described(label: "环境")
      },
      definitions: {
        "EnvType": Schema.enums(["DEV", "ONLINE"]),
      },
    );

    test("#entries", () {
      for (final e in schema
          .entries({}, EntryContext(definitions: schema.definitions))) {
        print("${e.key}：${e.type} ${e.label}");
      }
    });
  });
}
