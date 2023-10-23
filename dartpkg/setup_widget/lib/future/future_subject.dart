import 'dart:async';

import 'package:logr/logr.dart';
import 'package:rxdart/rxdart.dart';

typedef FutureDo<I, O> = Future<O> Function(I inputs);

class FutureSubject<I, O> {
  factory FutureSubject.of(FutureDo<I, O> futureDo) {
    final success$ = BehaviorSubject<O>();
    final requesting$ = PublishSubject<bool>();
    final error$ = PublishSubject<Object>();

    StreamSubscription<O>? sub;

    final req = PublishSubject<I>(
      onCancel: () {
        sub?.cancel();

        requesting$.close();
        error$.close();
        success$.close();
      },
    );

    sub = req.switchMap((input) {
      requesting$.add(true);
      return Stream.fromFuture(futureDo(input));
    }).handleError((err, stackTrace) {
      requesting$.add(false);
      Logger.current?.error(err, stackTrace: stackTrace);
      error$.add(err);
    }).doOnData((resp) {
      requesting$.add(false);
      success$.add(resp);
    }).listen(null);

    return FutureSubject(
      req,
      success: success$,
      error: error$,
      requesting: requesting$,
    );
  }

  StreamSink<I> _req;

  Stream<O> success;
  Stream<Object> error;
  Stream<bool> requesting;

  FutureSubject(
    this._req, {
    required this.success,
    required this.error,
    required this.requesting,
  });

  I? latestInput;

  request(I input) {
    this._req.add(latestInput = input);
  }
}
