import 'widget.dart';

Ref<T> ref<T>(T initial) {
  return SetupState.use((state) {
    return _RefImpl(state, initial);
  });
}

abstract class Ref<T> {
  T get value;

  set value(T v);
}

class _RefImpl<T> implements Ref<T> {
  final SetupState _state;

  _RefImpl(this._state, this._value);

  @override
  T get value => _value;
  T _value;

  @override
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    _state.trigger();
  }
}
