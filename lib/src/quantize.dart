import 'package:d4_array/d4_array.dart';

import 'linear.dart';
import 'scale.dart';

/// Quantize scales are similar to
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html),
/// except they use a discrete rather than continuous range.
///
/// The continuous input domain is divided into uniform segments based on the
/// number of values in (*i.e.*, the cardinality of) the output range. Each
/// range value *y* can be expressed as a quantized linear function of the
/// domain value *x: y = m round(x) + b*. See
/// [the quantized choropleth](https://observablehq.com/@d3/choropleth/2?intent=fork)
/// for an example.
///
/// {@category Quantize scales}
final class ScaleQuantize<Y> with Linearish<Y> implements Scale<num, Y> {
  late num _x0 = 0, _x1 = 1;
  late int _n;
  late List<num> _domain;
  late List<Y> _range;
  Y? unknown;

  /// Constructs a new quantize scale with the specified [domain] and [range].
  ///
  /// ```dart
  /// final color = ScaleQuantize(
  ///   domain: [0, 100],
  ///   range: schemeBlues[9],
  /// );
  /// ```
  ///
  /// If domain is not specified, it defaults to \[0, 1\].
  ///
  /// ```dart
  /// final color = ScaleQuantize(range: schemeBlues[9]);
  /// ```
  ScaleQuantize({List<num>? domain, required List<Y> range}) {
    this.range = range;
    if (domain != null) this.domain = domain;
  }

  /// Given a value in the input [domain], returns the corresponding value in
  /// the output [range]. For example, to apply a color encoding:
  ///
  /// ```dart
  /// final color = ScaleQuantize(
  ///   domain: [0, 1],
  ///   range: ["brown", "steelblue"],
  /// );
  /// color(0.49); // "brown"
  /// color(0.51); // "steelblue"
  /// ```
  ///
  /// Or dividing the domain into three equally-sized parts with different range
  /// values to compute an appropriate stroke width:
  ///
  /// ```dart
  /// final width = ScaleQuantize(
  ///   domain: [10, 100],
  ///   range: [1, 2, 4],
  /// );
  /// width(20); // 1
  /// width(50); // 2
  /// width(80); // 4
  /// ```
  @override
  call(x) {
    return x != null && !x.isNaN
        ? _range[bisectRight(_domain, x, lo: 0, hi: _n)]
        : unknown;
  }

  void _rescale() {
    var i = -1;
    _domain = List.filled(_n, 0);
    while (++i < _n) {
      _domain[i] = ((i + 1) * _x1 - (i - _n) * _x0) / (_n + 1);
    }
  }

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// final color = ScaleQuantize(range: schemeBlues[9]);
  /// color.domain = [0, 100];
  ///
  /// color.domain; // [0, 100]
  /// ```
  ///
  /// The two-element list of numbers must be in ascending order or the behavior
  /// of the scale is undefined.
  @override
  get domain => [_x0, _x1];
  @override
  set domain(domain) {
    _x0 = domain[0];
    _x1 = domain[1];
    _rescale();
  }

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// final color = ScaleQuantize(…);
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
    _n = range.length - 1;
    _rescale();
  }

  /// Returns the extent of values in the [domain] (*x0*, *x1*) for the
  /// corresponding value in the [range]\: the inverse of [call]. This method is
  /// useful for interaction, say to determine the value in the domain that
  /// corresponds to the pixel location under the mouse.
  ///
  /// ```dart
  /// final width = ScaleQuantize(
  ///   domain: [10, 100],
  ///   range: [1, 2, 4],
  /// );
  /// width.invertExtent(2); // (40, 70)
  /// ```
  (num, num) invertExtent(Y y) {
    var i = _range.indexOf(y);
    return i < 0
        ? (double.nan, double.nan)
        : i < 1
            ? (_x0, _domain[0])
            : i >= _n
                ? (_domain[_n - 1], _x1)
                : (_domain[i - 1], _domain[i]);
  }

  /// Returns the list of computed thresholds within the [domain].
  ///
  /// ```dart
  /// color.thresholds; // [0.2, 0.4, 0.6, 0.8]
  /// ```
  ///
  /// The number of returned thresholds is one less than the length of the
  /// [range]\: values less than the first threshold are assigned the first element
  /// in the range, whereas values greater than or equal to the last threshold
  /// are assigned the last element in the range.
  List<num> get thresholds => _domain.sublist(0);

  /// Returns an exact copy of this scale.
  ///
  /// ```dart
  /// fimal c1 = ScaleQuantize(range: schemeBlues[5]);
  /// final c2 = c1.copy();
  /// ```
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScaleQuantize<Y> copy() {
    return ScaleQuantize(domain: [_x0, _x1], range: _range)..unknown = unknown;
  }
}
