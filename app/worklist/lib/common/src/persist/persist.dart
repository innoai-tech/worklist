import 'dart:convert';

import 'package:logr/logr.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';

extension StorePersistExt<T> on Store<T> {
  connectPersist({
    required Driver driver,
    required T Function(Map<String, dynamic> data) valueFromJson,
  }) {
    final p = _Persistor(driver: driver, filename: "${name}.json");
    var ready = false;

    p
        .readJson(valueFromJson: valueFromJson)
        .asStream()
        .map(sink.add)
        .doOnData((data) => ready = true)
        .listenUntilUnmounted();

    stream
        .skipWhile((data) => !ready)
        .asyncMap((data) async => await p.saveJson(data))
        .listenOnMountedUntilUnmounted();
  }
}

class _Persistor {
  final Driver driver;
  final String filename;

  const _Persistor({required this.driver, required this.filename});

  Future<T> readJson<T>({
    required T Function(Map<String, dynamic> data) valueFromJson,
  }) async {
    try {
      final io = await driver.openFile("appdata/${filename}");
      final data = await io.openRead().then((f) => Utf8Codec().decodeStream(f));
      if (data != "") {
        return valueFromJson(JsonDecoder().convert(data));
      }
    } catch (err, stackTrace) {
      Logger.current?.error(
        err,
        msg: "load appdata/${filename} failed",
        stackTrace: stackTrace,
      );
    }
    return valueFromJson({});
  }

  Future<void> saveJson(Object? value) async {
    final io =
        await driver.openFile("appdata/${filename}", createIsNotExists: true);

    return await io.openWrite().then(
      (f) async {
        var jsonRAW = "{}";

        try {
          jsonRAW = JsonEncoder().convert(value);
        } catch (err) {
          Logger.current?.error(err, msg: "save appdata/${filename} failed");
        }

        return await Stream.fromIterable(
            [Utf8Codec().encode(jsonRAW).cast<int>()]).pipe(f);
      },
    );
  }
}
