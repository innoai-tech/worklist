import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class Subject<T> {
  StreamSink<T> get sink;
  ValueStream<T> get stream;
}

abstract class Store<T> extends Subject<T> {
  String get name;
}

class CommonStore<T> implements Store<T> {
  final ValueStream<T> stream;
  final StreamSink<T> sink;

  const CommonStore({
    required this.stream,
    required this.sink,
  });

  @protected
  get name => "unknown";
}
