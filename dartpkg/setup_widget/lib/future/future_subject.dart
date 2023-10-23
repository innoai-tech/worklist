import 'dart:async';

import 'package:rxdart/rxdart.dart';

typedef FutureDo<I, O> = Future<O> Function(I inputs);

class FutureSubject<I, O, E> extends Subject<O> implements ValueStream<O> {
  factory FutureSubject.create(FutureDo<I, O> futureDo) {
    final error$ = PublishSubject<E>();
    final request$ = PublishSubject<bool>();
    final output$ = BehaviorSubject<O>();

    StreamSubscription<O>? sub;

    final input$ = PublishSubject<I>(
      onCancel: () {
        sub?.cancel();
      },
    );

    sub = input$.switchMap((input) {
      request$.add(true);
      return Stream.fromFuture(futureDo(input));
    }).handleError((err) {
      request$.add(false);
      error$.add(err);
    }).doOnData((resp) {
      request$.add(false);
      output$.add(resp);
    }).listen(null);

    return FutureSubject(
      output$,
      input$: input$,
      error$: error$,
      request$: request$,
    );
  }

  final Subject<I> input$;
  final Subject<E> error$;
  final Subject<bool> request$;
  final BehaviorSubject<O> _output$;

  FutureSubject(
    this._output$, {
    required this.input$,
    required this.error$,
    required this.request$,
  }) : super(_output$, _output$.stream);

  request(I input) {
    this.input$.add(input);
  }

  @override
  Object get error => this._output$.error;

  @override
  Object? get errorOrNull => this._output$.errorOrNull;

  @override
  bool get hasError => this._output$.hasError;

  @override
  bool get hasValue => this._output$.hasValue;

  @override
  StackTrace? get stackTrace => this._output$.stackTrace;

  @override
  O get value => this._output$.value;

  @override
  O? get valueOrNull => this._output$.valueOrNull;
}
