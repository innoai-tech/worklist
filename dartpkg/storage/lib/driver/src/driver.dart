import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:setup_widget/setup_widget.dart';

abstract class Driver {
  static final context = Context<Driver>.create();

  Future<void> mkdir(String name, {bool? recursive});

  Future<void> remove(String name, {bool? recursive});

  Future<FileInterface> openFile(
    String name, {
    bool? createIsNotExists,
    FileMode? mode,
  });

  Future<void> rename(String oldName, String name);

  Future<FileInfo> stat(String name);
}

extension DriverUtf8IOExt on Driver {
  Future writeAsString(String name, String data) async {
    return writeAsBytes(name, utf8.encode(data));
  }

  Future readAsString(String name, {int? start, int? end}) async {
    return utf8.decode(await readAsBytes(name, start: start, end: end));
  }

  Future writeAsBytes(String name, List<int> data) async {
    final w = await openFile(name, createIsNotExists: true)
        .then((f) => f.openWrite());
    await Stream.fromIterable([data]).pipe(w);
  }

  Future<List<int>> readAsBytes(String name, {int? start, int? end}) async {
    return await openFile(name)
        .then((f) => f.openRead(start: start, end: end))
        .then((r) => r.readAsBytes());
  }
}

extension DriverListExt on Driver {
  Future<List<FileInfo>> list(String name, {int? count}) async {
    return await openFile(name).then((f) => f.readdir(count: count));
  }
}

abstract class FileInterface {
  Future<List<FileInfo>> readdir({int? count});

  Future<Stream<List<int>>> openRead({int? start, int? end});

  Future<StreamSink<List<int>>> openWrite();
}

abstract class FileInfo {
  String get name;

  bool get isDir;

  int get size;

  int get mode;

  DateTime get modTime;
}

class ErrNotExist implements Exception {
  final String path;

  const ErrNotExist({
    required this.path,
  });

  @override
  String toString() {
    return "${path} not exist";
  }
}

class ErrExist implements Exception {
  final String path;

  const ErrExist({
    required this.path,
  });

  @override
  String toString() {
    return "${path} exist";
  }
}

extension BytesStreamReadExt on Stream<List<int>> {
  Future<List<int>> readAsBytes() async {
    final b = BytesBuilder(copy: false);

    await forEach((part) {
      b.add(part);
    });

    return b.toBytes();
  }
}
