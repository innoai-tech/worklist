import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';

class KeyPath extends Iterable {
  factory KeyPath.from(Iterable path) {
    return KeyPath(path: [...path]);
  }

  final List path;

  const KeyPath({
    this.path = const [],
  });

  KeyPath entry(dynamic key) {
    if (key == null) {
      return this;
    }
    return KeyPath(path: [...path, key]);
  }

  @override
  String toString() {
    return "/${this.path.map((e) => jsonEncode(e)).join("/")}";
  }

  @override
  Iterator get iterator => this.path.iterator;
}

dynamic get(dynamic target, KeyPath keyPath) {
  final keyOrIdx = keyPath.firstOrNull;

  if (keyPath.length == 1) {
    if (target is Map || target is List) {
      return target[keyOrIdx];
    }
    return null;
  }

  final subKeyPath = KeyPath.from(keyPath.skip(1));

  return get(target[keyOrIdx], subKeyPath);
}

void set(dynamic values, KeyPath keyPath, value) {
  final keyOrIdx = keyPath.firstOrNull;

  if (keyPath.length == 1) {
    values[keyOrIdx] = value;
    return;
  }

  final subKeyPath = KeyPath.from(keyPath.skip(1));
  final subKeyOrIndex = subKeyPath.firstOrNull;

  if (values is List && keyOrIdx is int) {
    if (keyOrIdx >= values.length) {
      for (var i = values.length; i <= keyOrIdx; i++) {
        values.add(null);
      }
    }
  }

  if (values[keyOrIdx] == null) {
    if (subKeyOrIndex is int) {
      values[keyOrIdx] = [];
    } else {
      values[keyOrIdx] = Map<String, dynamic>.from({});
    }
  }

  set(values[keyOrIdx], subKeyPath, value);

  return;
}

dynamic patch(dynamic values, KeyPath keyPath, dynamic value) {
  if (keyPath.length == 0) {
    return value;
  }

  final keyOrIdx = keyPath.firstOrNull;

  if (values == null) {
    if (keyOrIdx is int) {
      values = List.generate(keyOrIdx + 1, (i) => null);
    } else if (keyOrIdx is String) {
      values = Map<String, dynamic>.from({});
    } else {
      throw Exception("invalid key $keyOrIdx");
    }
  }

  final current = switch (values) {
    List x => x.getOrNull(keyOrIdx),
    Map<String, dynamic> x => x[keyOrIdx],
    Object() => null,
    null => null,
  };

  if (keyPath.length == 1) {
    if (current == value) {
      return values;
    }

    if (values is List) {
      List list = values;
      return List.generate(max(keyOrIdx + 1, list.length), (i) => null)
          .mapIndexed((idx, val) {
        if (idx == keyOrIdx) {
          return value;
        }
        return list.getOrNull(idx);
      }).toList();
    }

    return Map<String, dynamic>.from({
      ...values,
      keyOrIdx: value,
    });
  }

  final subKeyPath = KeyPath.from(keyPath.skip(1));
  final subValues = patch(current, subKeyPath, value);

  if (subValues == current) {
    return values;
  }

  if (values is List) {
    List list = values;

    return List.generate(max(keyOrIdx + 1, list.length), (i) {
      if (i == keyOrIdx) {
        return subValues;
      }
      return list.getOrNull(i);
    }).toList();
  }

  return Map<String, dynamic>.from({
    ...?values,
    keyOrIdx: subValues,
  });
}

Future<T> replaceWith<T>(
  T values,
  FutureOr<dynamic> Function(dynamic value, KeyPath keyPath) replacer, {
  KeyPath? keyPath,
}) async {
  if (values is List) {
    final replaced = [];

    for (var i = 0; i < values.length; i++) {
      replaced.add(await replaceWith(
        values[i],
        replacer,
        keyPath: (keyPath ?? KeyPath()).entry(i),
      ));
    }

    return replaced as T;
  }

  if (values is Map<String, dynamic>) {
    final replaced = Map<String, dynamic>.of({});

    for (final key in values.keys) {
      replaced[key] = await replaceWith(
        values[key],
        replacer,
        keyPath: (keyPath ?? KeyPath()).entry(key),
      );
    }

    return replaced as T;
  }

  return await replacer(values, keyPath ?? KeyPath());
}

extension _ListExt<T> on List<T> {
  T? getOrNull(int idx) {
    if (idx < length) {
      return this[idx];
    }
    return null;
  }
}
