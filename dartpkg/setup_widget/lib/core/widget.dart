import 'dart:async';

import 'package:flutter/widgets.dart';

typedef WidgetBuilder = Widget Function();

typedef Setup<T extends SetupWidget> = WidgetBuilder Function(
  SetupContext<T> context,
);

abstract class SetupWidget extends StatefulWidget {
  const SetupWidget({Key? key}) : super(key: key);

  @protected
  Setup get setup;

  @override
  SetupState<SetupWidget> createState() => SetupState<SetupWidget>();

  Setup createSetup<T extends SetupWidget>(
    Setup<T> s,
  ) =>
      (context) => s(context.cast());
}

abstract class SetupContext<T extends SetupWidget> {
  SetupContext<W> cast<W extends SetupWidget>();

  T get widget;

  BuildContext get context;
}

class _SetupContextImpl<T extends SetupWidget> implements SetupContext<T> {
  SetupState state;

  _SetupContextImpl(this.state);

  @override
  T get widget {
    return state.widget as T;
  }

  @override
  SetupContext<W> cast<W extends SetupWidget>() {
    return _SetupContextImpl<W>(state);
  }

  @override
  BuildContext get context {
    return state.context;
  }
}

class SetupState<T extends SetupWidget> extends State<T> {
  SetupState() : super();

  final Lifecycle lifecycle = Lifecycle();

  WidgetBuilder? _builder;

  @override
  void initState() {
    super.initState();

    _runZoned(() {
      _builder = widget.setup(_SetupContextImpl(this));
    });

    if (mounted) {
      lifecycle.mounted.trigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _builder!();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    lifecycle.updated.trigger();
  }

  @override
  void dispose() {
    lifecycle.unmounted.trigger();
    lifecycle.dispose();
    super.dispose();
  }

  // trigger state update
  void trigger() {
    if (mounted) {
      super.setState(() {});
    }
  }

  _runZoned(VoidCallback fn) {
    return runZoned(fn, zoneValues: {
      SetupState: this,
    });
  }

  static R use<R>(R Function(SetupState e) fn) {
    return fn(Zone.current[SetupState] as SetupState);
  }
}

abstract class EventListener {
  static of(VoidCallback action) {
    return _EventListenerImpl(action);
  }

  @protected
  void trigger();

  @protected
  void dispose();
}

class _EventListenerImpl implements EventListener {
  VoidCallback action;

  _EventListenerImpl(this.action);

  @override
  void trigger() {
    action();
  }

  @override
  void dispose() {}
}

class Lifecycle {
  final GroupedEventListener mounted = GroupedEventListener();
  final GroupedEventListener updated = GroupedEventListener();
  final GroupedEventListener unmounted = GroupedEventListener();

  dispose() {
    mounted.dispose();
    updated.dispose();
    unmounted.dispose();
  }
}

class GroupedEventListener implements EventListener {
  final Set<EventListener> _watchers = {};

  void add(EventListener l) {
    _watchers.add(l);
  }

  @override
  void trigger() {
    for (final l in _watchers) {
      l.trigger();
    }
  }

  @override
  void dispose() {
    for (final l in _watchers) {
      l.dispose();
    }
    _watchers.clear();
  }
}
