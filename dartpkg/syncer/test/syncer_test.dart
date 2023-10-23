import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:syncer/syncer.dart';
import 'package:test/test.dart';

void main() {
  test("Task", () async {
    await Task.parallel(
      List.generate(
        10,
        (index) => Task.of(
          (ctx) async {
            final bytes =
                List.generate(10, (index) => List.generate(1000, (index) => 1));

            final source = Stream.fromIterable(bytes)
                .interval(Duration(milliseconds: 10 * index));

            return source.doOnData((buf) {
              ctx.addTransformed(buf.length);
            }).pipe(PublishSubject<List<int>>());
          },
          id: "1",
          size: 10 * 1000,
        ),
      ),
      id: "parallel",
      maxParallels: 2,
    ).sync(onProgress: (task) {
      print(task.progress);
    });
  });
}
