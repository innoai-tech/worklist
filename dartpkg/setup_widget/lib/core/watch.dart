import 'widget.dart';

void watchEffect(void Function() action) {
  return SetupState.use((state) {
    state.lifecycle.mounted.add(EventListener.of(action));
    state.lifecycle.updated.add(EventListener.of(action));
  });
}

void watch<T>(T Function() valueGetter, void Function(T value, T prev) action) {
  return SetupState.use((state) {
    return state.lifecycle.updated.add(_ValueWatcher<T>(
      valueGetter: valueGetter,
      action: action,
    ));
  });
}

class _ValueWatcher<T> implements EventListener {
  T Function() valueGetter;
  void Function(T value, T prev) action;

  _ValueWatcher({
    required this.valueGetter,
    required this.action,
  }) {
    _value = valueGetter();
  }

  late T _value;

  @override
  void trigger() {
    final next = valueGetter();
    if (next != _value) {
      action(next, _value);
      _value = next;
    }
  }

  @override
  void dispose() {}
}
