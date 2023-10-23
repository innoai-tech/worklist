import '../core/core.dart';

extension UntilUnmountedListener<T> on Stream<T> {
  void listenUntilUnmounted(
    Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    onUnmounted(() => sub.cancel());
  }
}
