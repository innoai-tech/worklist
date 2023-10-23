import 'dart:async';

import 'package:rxdart/rxdart.dart';

import './task.dart';

abstract class TaskSyncer {
  static TaskSyncer create() {
    return _TaskSyncer();
  }

  Stream<DateTime> get stream;

  add(Task task);
}

class _TaskSyncer implements TaskSyncer {
  List<Task> _taskQueue = [];

  Map<String, Task> _runningTasks = {};

  BehaviorSubject<DateTime> _progressing =
      BehaviorSubject.seeded(DateTime.now());

  Stream<DateTime> get stream {
    return _progressing.doOnListen(() => _start()).doOnCancel(() => _stop());
  }

  add(Task task) {
    _taskQueue.add(task);
  }

  Task? _taskTask() {
    if (_taskQueue.length > 0) {
      final task = _taskQueue[0];
      _taskQueue = _taskQueue.sublist(1);
      return task;
    }
    return null;
  }

  _checkAndDoTask() async {
    if (_runningTasks.length < 2) {
      final task = _taskTask();
      if (task != null) {
        _runningTasks[task.id] = task;

        task.sync(
          onDone: () {
            _runningTasks.remove(task.id);
            _progressing.add(DateTime.now());
          },
          onProgress: (task) {
            _progressing.add(DateTime.now());
          },
        );
      }
    }
  }

  int listenersCount = 0;
  StreamSubscription? sub;

  _start() {
    listenersCount++;

    if (sub != null) {
      return;
    }

    sub = Stream.periodic(Duration(seconds: 1))
        .asyncMap((event) => _checkAndDoTask())
        .listen((event) {});
  }

  _stop() {
    listenersCount--;

    if (listenersCount == 0) {
      sub?.cancel();
      sub = null;
    }
  }
}
