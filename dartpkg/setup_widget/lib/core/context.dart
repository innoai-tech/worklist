import "package:flutter/cupertino.dart";
import "package:provider/provider.dart" as provider;

import "setup_widget.dart";

abstract class Context<T> {
  factory Context.create([T Function()? getDefaultValue]) {
    return _Context<T>(getDefaultValue: getDefaultValue);
  }

  Widget provide({
    required Widget child,
    T? value,
  });

  T use();
}

class _Context<T> implements Context<T> {
  final T Function()? getDefaultValue;

  _Context({
    this.getDefaultValue,
  });

  T? _defaultValue;

  T get _default {
    if (getDefaultValue != null) {
      return _defaultValue ??= getDefaultValue!();
    }
    throw new Exception("Context<${T.runtimeType}> missing default values");
  }

  @override
  Widget provide({
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
