import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'driver.dart';

class FsDriver implements Driver {
  Directory root;

  FsDriver({
    required this.root,
  });

  String pathname(String name) {
    return p.normalize(p.join(root.path, name));
  }

  @override
  Future<void> mkdir(name, {recursive}) async {
    final p = pathname(name);
    await Directory(p).create(recursive: recursive ?? false);
  }

  @override
  Future<FileInterface> openFile(name, {createIsNotExists, mode}) async {
    final p = pathname(name);

    try {
      await stat(name);
    } catch (e) {
      if ((e is ErrNotExist) && (createIsNotExists ?? false)) {
        await File(p).create(recursive: true);
      }
    }
    return _File(filename: p);
  }

  @override
  Future<void> remove(name, {recursive}) async {
    try {
      final info = await stat(name);
      if (info.isDir) {
        await Directory(pathname(name)).delete(recursive: recursive ?? true);
      } else {
        await File(pathname(name)).delete(recursive: recursive ?? true);
      }
    } catch (e) {
      if (!(e is ErrNotExist)) {
        rethrow;
      }
    }
  }

  @override
  Future<void> rename(oldName, name) async {
    final f = File(pathname(oldName));
    if (!(await f.exists())) {
      throw ErrNotExist(path: oldName);
    }
    await f.rename(pathname(name));
  }

  Future<FileInfo> stat(name) async {
    final p = pathname(name);
    var stat = await FileStat.stat(p);
    if (stat.type == FileSystemEntityType.notFound) {
      throw ErrNotExist(path: p);
    }
    return _FileInfo(
      name: _FileInfo.filename(Uri.file(p)),
      stat: stat,
    );
  }
}

class _FileInfo implements FileInfo {
  final FileStat stat;
  final String name;

  _FileInfo({
    required this.name,
    required this.stat,
  });

  @override
  bool get isDir => stat.type == FileSystemEntityType.directory;

  @override
  DateTime get modTime => stat.modified;

  @override
  int get mode => stat.mode;

  @override
  int get size => stat.size;

  String toString() {
    return "${name} ${stat.modeString()} ${size} ${modTime}";
  }

  static filename(Uri uri) {
    final pathSegments = uri.pathSegments;
    final lastIndex = pathSegments.lastIndexWhere((p) => p != "");
    return pathSegments[lastIndex];
  }
}

class _File implements FileInterface {
  final String filename;

  const _File({
    required this.filename,
  });

  @override
  Future<Stream<List<int>>> openRead({int? start, int? end}) async {
    return await File(filename).openRead(start, end);
  }

  @override
  Future<StreamSink<List<int>>> openWrite() async {
    return await File(filename).openWrite();
  }

  @override
  Future<List<FileInfo>> readdir({int? count}) async {
    var c = -1;

    return await Directory(filename).list().takeWhile((e) {
      c++;
      if (count != null) {
        return c <= count;
      }
      return true;
    }).asyncMap((entry) async {
      return _FileInfo(
        name: _FileInfo.filename(entry.uri),
        stat: (await entry.stat()),
      );
    }).toList();
  }
}
