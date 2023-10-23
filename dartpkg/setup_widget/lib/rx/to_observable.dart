import 'package:rxdart/rxdart.dart';

import './observable_ref.dart';
import '../core/core.dart';

ValueStream<T> toObservable<T>(T Function() getValue) {
  final s = observableRef(getValue());
  watch(getValue, (value, prev) {
    if (value != s.value) {
      s.value = value;
    }
  });
  return s;
}
