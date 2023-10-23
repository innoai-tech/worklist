extension ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}

extension BoolExt on bool {
  R? ifTrue<R>(R Function() op) {
    if (this) {
      return op();
    }
    return null;
  }

  R? ifFalse<R>(R Function() op) {
    if (!this) {
      return op();
    }
    return null;
  }
}
