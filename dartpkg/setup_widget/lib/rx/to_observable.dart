import 'package:rxdart/rxdart.dart';

import '../core/core.dart';
import './observable_ref.dart';

ValueStream<T> toObservable<T>(T Function() getValue) {
  final s = observableRef(getValue());

  watch(getValue, (value, prev) {
    if (value != s.value) {
      s.value = value;
    }
  });

  return s.stream;
}
