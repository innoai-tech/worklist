import "package:rxdart/rxdart.dart";

import "../core/core.dart";

ObservableRef<T> observableRef<T>(T value) {
  return ObservableRef.seeded(value);
}

class ObservableRef<T> extends Subject<T> implements ValueStream<T> {
  factory ObservableRef.seeded(
    T seedValue, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final subject$ = BehaviorSubject.seeded(seedValue);
    final valueWrapper = ref(seedValue);

    return ObservableRef<T>._(
      subject$,
      valueWrapper,
    );
  }

  BehaviorSubject<T> _subject;
  Ref<T> _ref;

  ObservableRef._(this._subject, this._ref) : super(_subject, _subject.stream);

  @override
  T get value => this._ref.value;

  @override
  void add(T event) {
    if (event != this._ref.value) {
      this._ref.value = event;
      super.add(event);
    }
  }

  set value(T value) => this.add(value);

  @override
  bool get hasValue => value != null;

  @override
  T? get valueOrNull => value;

  @override
  bool get hasError => this._subject.hasError;

  @override
  Object get error => this._subject.error;

  @override
  Object? get errorOrNull => this._subject.errorOrNull;

  @override
  StackTrace? get stackTrace => this._subject.stackTrace;
}
