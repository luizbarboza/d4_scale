import 'dart:math' as math;

import 'package:d4_array/d4_array.dart';

import 'linear.dart';
import 'scale.dart';

/// Quantile scales map a sampled input domain to a discrete range.
///
/// The domain is considered continuous and thus the scale will accept any
/// reasonable input value; however, the domain is specified as a discrete set
/// of sample values. The number of values in (the cardinality of) the output
/// range determines the number of quantiles that will be computed from the
/// domain. To compute the quantiles, the domain is sorted, and treated as a
/// [population of discrete values](https://en.wikipedia.org/wiki/Quantile#Quantiles_of_a_population);
/// see [quantile]. See
/// [this quantile choropleth](https://observablehq.com/@d3/quantile-choropleth)
/// for an example.
///
/// {@category Quantile scales}
final class ScaleQuantile<Y> with Linearish<Y> implements Scale<num, Y> {
  late List<num> _domain;
  List<Y> _range = [];
  late List<num> _thresholds;
  Y? unknown;

  /// Constructs a new quantile scale with the specified [domain] and [range].
  ///
  /// ```dart
  /// final color = ScaleQuantile(
  ///   domain: penguins.map((d) => d["body_mass_g"]),
  ///   range: schemeBlues[5],
  /// );
  /// ```
  ScaleQuantile({required List<num?> domain, required List<Y> range})
      : _range = range {
    this.domain = domain;
  }

  void _rescale() {
    var i = 0, n = math.max(1, _range.length);
    _thresholds = List.filled(n - 1, 0);
    while (++i < n) {
      _thresholds[i - 1] = quantileSorted(_domain, i / n)!;
    }
  }

  /// Given a value in the input [domain], returns the corresponding value in
  /// the output [range].
  ///
  /// ```dart
  /// color(3000); // "#eff3ff"
  /// color(4000); // "#6baed6"
  /// color(5000); // "#08519c"
  /// ```
  @override
  call(x) {
    return x != null && !x.isNaN
        ? _range[bisectRight(_thresholds, x)]
        : unknown;
  }

  /// Returns the extent of values in the [domain] (*x0*, *x1*) for the
  /// corresponding value in the [range]\: the inverse of [call].
  ///
  /// ```dart
  /// color.invertExtent("#eff3ff"); // (2700, 3475)
  /// color.invertExtent("#6baed6"); // (3800, 4300)
  /// color.invertExtent("#08519c"); // (4950, 6300)
  /// ```
  ///
  /// This method is useful for interaction, say to determine the value in the
  /// domain that corresponds to the pixel location under the mouse.
  (num, num) invertExtent(Y y) {
    var i = _range.indexOf(y);
    return i < 0
        ? (double.nan, double.nan)
        : (
            i > 0 ? _thresholds[i - 1] : _domain[0],
            i < _thresholds.length
                ? _thresholds[i]
                : _domain[_domain.length - 1]
          );
  }

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// const color = ScaleQuantile(
  ///   domain: …,
  ///   range: schemeBlues[5],
  /// );
  /// color.domain = penguins.map((d) => d["body_mass_g"]);
  ///
  /// color.domain; // [2700, 2850, 2850, 2900, 2900, 2900, 2900, …]
  /// ```
  ///
  /// The list must not be empty, and must contain at least one numeric value;
  /// [double.nan] and null values are ignored and not considered part of the
  /// sample population. A copy of the input list is sorted and stored
  /// internally.
  @override
  get domain => _domain.sublist(0);
  @override
  set domain(List<num?> domain) {
    _domain = [];
    for (var d in domain) {
      if (d != null && !d.isNaN) _domain.add(d);
    }
    _domain = sort(_domain, ascending);
    _rescale();
  }

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// const color = ScaleQuantile(
  ///   domain: penguins.map((d) => d["body_mass_g"]),
  ///   range: …,
  /// );
  /// color.range = schemeBlues[5];
  ///
  /// color.range; // ["#eff3ff", "#bdd7e7", "#6baed6", "#3182bd", "#08519c"]
  /// ```
  ///
  /// The list must not be empty, and may contain any type of value. The number
  /// of values in (the cardinality, or length, of) the [range] list determines
  /// the number of quantiles that are computed. For example, to compute
  /// quartiles, [range] must be an list of four elements such as
  /// \[0, 1, 2, 3\].
  @override
  get range => _range.sublist(0);
  @override
  set range(range) {
    _range = range;
    _rescale();
  }

  /// Returns the quantile thresholds.
  ///
  /// ```dart
  /// color.quantiles // [3475, 3800, 4300, 4950]
  /// ```
  ///
  /// If the [range] contains *n* discrete values, the returned list will
  /// contain *n* - 1 thresholds. Values less than the first threshold are
  /// considered in the first quantile; values greater than or equal to the
  /// first threshold but less than the second threshold are in the second
  /// quantile, and so on. Internally, the thresholds array is used with bisect
  /// (see [bisectRight]) to find the output quantile associated with the given
  /// input value.
  List<num> get quantiles => _thresholds.sublist(0);

  /// Returns an exact copy of this scale.
  ///
  /// ```dart
  /// final c1 = ScaleQuantile(…);
  /// final c2 = c1.copy();
  /// ```
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScaleQuantile<Y> copy() {
    return ScaleQuantile(domain: _domain, range: _range)..unknown = unknown;
  }
}
