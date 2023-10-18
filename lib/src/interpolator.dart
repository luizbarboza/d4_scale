typedef Interpolator<T> = T Function(num);

// interpolator factory
typedef Interpolate<T> = Interpolator<T> Function(T, T);

// piecewise interpolator factory
typedef Piecewise<T> = Interpolator<T> Function(
    List<num>, List<T>, Interpolate<T>);
