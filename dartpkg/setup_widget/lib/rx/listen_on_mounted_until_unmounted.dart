import 'dart:async';

import '../core/core.dart';

extension OnMountedUntilUnmountedListener<T> on Stream<T> {
  void listenOnMountedUntilUnmounted(
    Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    StreamSubscription<T>? sub;

    onMounted(() {
      sub = listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    });

    onUnmounted(() => sub?.cancel());
  }
}
