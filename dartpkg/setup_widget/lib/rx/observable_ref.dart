import "dart:async";

import "package:rxdart/rxdart.dart" show ValueStream, BehaviorSubject;

import "../core/core.dart";
import "subject.dart";

ObservableRef<T> observableRef<T>(T value) {
  return ObservableRef.seeded(value);
}

abstract class ObservableRef<T> implements Subject<T>, Ref<T> {
  factory ObservableRef.seeded(
    T seedValue, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    return _ObservableRef<T>(
      subject: BehaviorSubject.seeded(seedValue),
      ref: ref(seedValue),
    );
  }
}

class _ObservableRef<T> implements ObservableRef<T> {
  final BehaviorSubject<T> subject;
  final Ref<T> ref;

  const _ObservableRef({
    required this.ref,
    required this.subject,
  });

  ValueStream<T> get stream => subject.stream;

  StreamSink<T> get sink => subject.sink;

  T get value => this.ref.value;

  set value(T value) {
    if (value != this.ref.value) {
      sink.add(value);
      this.ref.value = value;
    }
  }
}
