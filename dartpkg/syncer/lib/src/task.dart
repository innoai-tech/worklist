import 'dart:async';

abstract class TaskContext {
  addTransformed(int n);
}

abstract class Task {
  static Task parallel(
    List<Task> tasks, {
    required String id,
    int? maxParallels,
  }) {
    return _TaskParallel(
      tasks: tasks,
      id: id,
      maxParallel: maxParallels ?? 2,
    );
  }

  static Task of(
    Future<void> Function(TaskContext context) wait, {
    required int size,
    required String id,
  }) {
    return _Task(
      wait: wait,
      size: size,
      id: id,
    );
  }

  String get id;

  int get size;

  int get transformed;

  bool get completed;

  Future<void> sync({
    Function(Task task)? onProgress,
    Function? onDone,
  });
}

class _TaskParallel implements Task {
  List<Task> tasks;
  String id;
  int maxParallel;

  _TaskParallel({
    required this.tasks,
    required this.id,
    required this.maxParallel,
  });

  Future<void> sync({
    Function(Task task)? onProgress,
    Function? onDone,
  }) async {
    int idx = -1;

    await Future.wait(List.generate(maxParallel, (index) async {
      while (idx < tasks.length) {
        idx++;

        if (idx < tasks.length) {
          await tasks[idx].sync(
            onProgress: (task) {
              onProgress?.let((onProgress) => onProgress(this));
            },
          );
        }
      }
    }));

    onDone?.let((onDone) => onDone());

    return;
  }

  @override
  int get size => this.tasks.fold(0, (size, task) => size + task.size);

  @override
  int get transformed =>
      this.tasks.fold(0, (transformed, task) => transformed + task.transformed);

  @override
  bool get completed =>
      this.tasks.fold(true, (completed, task) => completed && task.completed);
}

class _Task implements Task, TaskContext {
  final String id;
  final int size;

  final Future<void> Function(TaskContext context) wait;

  _Task({
    required this.wait,
    required this.size,
    required this.id,
  });

  int transformed = 0;
  bool completed = false;

  Function(Task task)? _onProgress;

  addTransformed(int n) {
    transformed += n;
    _onProgress?.let((onProgress) => onProgress(this));
  }

  Future<void> sync({
    Function(Task task)? onProgress,
    Function? onDone,
  }) async {
    _onProgress = onProgress;
    await wait(this);
    onDone?.let((onDone) => onDone());
    transformed = size;
    completed = true;
    _onProgress = null;
  }
}

extension _ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}

class Progress {
  final String id;
  final double percentage;

  const Progress({
    required this.id,
    required this.percentage,
  });

  @override
  String toString() {
    return "${id}: ${percentage}%";
  }
}

extension TaskProgress on Task {
  Progress get progress => Progress(
        id: id,
        percentage: (transformed.toDouble() / size.toDouble()) * 100,
      );
}
