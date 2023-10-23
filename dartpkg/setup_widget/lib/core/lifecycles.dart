import 'dart:ui';

import 'widget.dart';

void onMounted(VoidCallback action) {
  return SetupState.use((state) {
    state.lifecycle.mounted.add(EventListener.of(action));
  });
}

void onUpdated(VoidCallback action) {
  return SetupState.use((state) {
    state.lifecycle.updated.add(EventListener.of(action));
  });
}

void onUnmounted(VoidCallback action) {
  return SetupState.use((state) {
    state.lifecycle.unmounted.add(EventListener.of(action));
  });
}
