extension Unwrap on Object {
  /// TODO:
  ///
  T? unwrapOrNull<T>([final T Function(T)? callback]) => switch (this) {
        final T value => callback == null ? value : callback(value),
        _ => null,
      };
}
