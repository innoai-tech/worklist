import 'package:flutter_test/flutter_test.dart';
import 'package:setup_widget/setup_widget.dart';

void main() {
  test('FutureSubject', () async {
    final odd$ = FutureSubject.create((int i) async {
      if (i % 2 == 0) {
        throw Exception("requires odd");
      }
      return await Future.delayed(
        const Duration(milliseconds: 100),
      ).then((value) => i * i);
    });

    List<int> results = [];
    List<dynamic> errors = [];
    List<bool> requesting = [];

    final retSub = odd$.listen((value) {
      results.add(value);
    });

    final errorSub = odd$.error$.listen((value) {
      errors.add(value);
    });

    final requestingSub = odd$.request$.listen((value) {
      requesting.add(value);
    });

    for (var i = 1; i < 6; i++) {
      await Future.delayed(
        const Duration(milliseconds: 150),
      ).then((value) => odd$.request(i));
    }

    await Future.delayed(const Duration(milliseconds: 100 * 10));

    await retSub.cancel();
    await errorSub.cancel();
    await requestingSub.cancel();

    expect(results, [1, 9, 25]);
    expect(errors.length, 2);
    expect(requesting, [
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
    ]);
  });
}
