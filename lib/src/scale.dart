import 'package:d4_scale/src/sequential.dart';

import 'continuous.dart';
import 'diverging.dart';

/// A generic mapper from an input domain to an output range.
abstract interface class Scale<X, Y> {
  /// Given a value from the [domain], returns the corresponding value from the
  /// [range].
  Y? call(X? x);

  /// The scale's domain that specifies the input values.
  List<X> get domain;
  set domain(List<X> domain);

  /// The scale's range that specifies the output values.
  List<Y> get range;
  set range(List<Y> range);

  /// Returns an exact copy of this scale.
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  Scale<X, Y> copy();
}

extension ScaleTransform<Y> on Scale<num, Y> {
  void transform(num Function(num) t, num Function(num) u) {
    final s = this;
    if (s is ScaleContinuousBase<num, Y>) {
      s.transform(t, u);
    } else if (s is ScaleSequentialBase<Y>) {
      s.transform(t);
    } else if (s is ScaleDivergingBase<Y>) {
      s.transform(t);
    }
  }
}
