import "package:flutter/cupertino.dart";
import "package:provider/provider.dart" as provider;

import "widget.dart";

abstract class Context<T> {
  factory Context.create(T Function() createDefault) {
    return _Context<T>(createDefault);
  }

  Widget Provider({
    required Widget child,
    T? value,
  });

  T use();
}

class _Context<T> implements Context<T> {
  final T Function() createDefault;

  _Context(this.createDefault);

  T? _defaultValue;

  T get _default {
    return _defaultValue ??= createDefault();
  }

  @override
  Widget Provider({
    required Widget child,
    T? value,
  }) {
    return provider.Provider(
      create: (ctx) {
        return _Wrapper(value ?? _default);
      },
      child: child,
    );
  }

  @override
  T use() {
    return SetupState.use((s) {
      try {
        return s.context.read<_Wrapper<T>>().value;
      } catch (_) {
        return _default;
      }
    });
  }
}

class _Wrapper<T> {
  T value;

  _Wrapper(this.value);
}
