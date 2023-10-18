import 'package:d4_array/d4_array.dart';
import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'quantile.dart';
import 'scale.dart';

/// A sequential scale with a *p*-quantile transform, analogous to a
/// [ScaleQuantile].
///
/// {@category Sequential scales}
final class ScaleSequentialQuantile<Y> implements Scale<num, Y> {
  late List<num> _domain = [];
  Y Function(num) interpolator;

  /// Returns a new sequential scale with a *p*-quantile transform, analogous to
  /// a [ScaleQuantile].
  ScaleSequentialQuantile({List<num?>? domain, required this.interpolator}) {
    if (domain != null) this.domain = domain;
  }

  static ScaleSequentialQuantile<num> number(
      {List<num?>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequentialQuantile(domain: domain, interpolator: interpolator);
  }

  static ScaleSequentialQuantile<Object?> dynamic(
      {List<num?>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequentialQuantile(domain: domain, interpolator: interpolator);
  }

  @override
  call(x) {
    return x != null && !x.isNaN
        ? interpolator(
            (bisectRight(_domain, x, lo: 1) - 1) / (_domain.length - 1))
        : null;
  }

  @override
  set domain(List<num?> domain) {
    _domain = [];
    for (var d in domain) {
      if (d != null && !d.isNaN) _domain.add(d);
    }
    _domain = sort(_domain, ascending);
  }

  @override
  get domain => _domain.sublist(0);

  @override
  set range(range) {
    final r0 = range[0], r1 = range[1];
    interpolator = interpolate(r0, r1) as Y Function(num);
  }

  @override
  get range {
    final range = <Y>[];
    for (var i = 0; i < _domain.length; i++) {
      range.add(interpolator(i / (_domain.length - 1)));
    }
    return range;
  }

  /// Returns an list of *n* + 1 quantiles.
  ///
  /// ```dart
  /// final color = ScaleSequentialQuantile(…)
  ///   ..domain = penguins.map((d) => d["body_mass_g"])
  ///   ..interpolator = interpolateBlues;
  ///
  /// color.quantiles(4); // [2700, 3550, 4050, 4750, 6300]
  /// ```
  ///
  /// For example, if *n* = 4, returns an list of five numbers: the minimum
  /// value, the first quartile, the median, the third quartile, and the maximum.
  List<num?> quantiles(int n) {
    return [for (var i = 0; i < n + 1; i++) quantile(_domain, i / n)];
  }

  @override
  ScaleSequentialQuantile<Y> copy() {
    return ScaleSequentialQuantile(domain: _domain, interpolator: interpolator);
  }
}
