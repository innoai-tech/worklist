import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import '../core/core.dart';
import 'listen_until_unmounted.dart';

extension OnDataBuilderForStream<T> on Stream<T> {
  Widget buildOnData(Widget Function(T data) build) {
    return _StreamBuilder<T>(
      stream: this,
      builder: (BuildContext ctx, T? data) {
        if (data != null) {
          return build(data);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StreamBuilder<T> extends SetupWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext context, T? data) builder;

  const _StreamBuilder({
    required this.stream,
    required this.builder,
  });

  @override
  Setup<SetupWidget> get setup => createSetup<_StreamBuilder<T>>((s) {
        final w = ref<T?>(null);

        final stream = s.widget.stream;
        if (stream is ValueStream<T>) {
          w.value = stream.valueOrNull;
        }

        s.widget.stream.listenUntilUnmounted((value) {
          if (value != w.value) {
            w.value = value;
          }
        });

        return () {
          return s.widget.builder(s.context, w.value);
        };
      });
}
