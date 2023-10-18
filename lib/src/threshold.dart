import 'dart:math' as math;

import 'package:d4_array/d4_array.dart';

import 'scale.dart';

/// Threshold scales are similar to
/// [quantize scales](https://pub.dev/documentation/d4_scale/latest/topics/Quantize%20scales-topic.html),
/// except they allow you to map arbitrary subsets of the domain to discrete
/// values in the range.
///
/// The input domain is still continuous, and divided into slices based on a set
/// of threshold values. See
/// [this choropleth](https://observablehq.com/@d3/threshold-choropleth) for an
/// example.
///
/// {@category Threshold scales}
final class ScaleThreshold<X, Y> implements Scale<X, Y> {
  List<X> _domain = [];
  late List<Y> _range;
  Y? unknown;
  late int _n;

  /// Constructs a new threshold scale with the specified [domain] and [range].
  ///
  /// ```dart
  /// final color = ScaleThreshold(
  ///   domain: [0, 1],
  ///   range: ["red", "white", "blue"],
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0.5\].
  ///
  /// ```dart
  /// final color = ScaleThreshold(range: ["red", "blue"]);
  /// color(0); // "red"
  /// color(1); // "blue"
  /// ```
  ScaleThreshold({required List<X> domain, required List<Y> range}) {
    this.range = range;
    this.domain = domain;
  }

  /// Given a value in the input [domain], returns the corresponding value in
  /// the output [range]. For example:
  ///
  /// ```dart
  /// final color = ScaleThreshold(
  ///   domain: [0, 1],
  ///   range: ["red", "white", "green"],
  /// );
  /// color(-1); // "red"
  /// color(0); // "white"
  /// color(0.5); // "white"
  /// color(1); // "green"
  /// color(1000); // "green"
  /// ```
  @override
  call(x) {
    return x != null && x is Comparable && (x is! num || !x.isNaN)
        ? _range[bisectRight(_domain, x, lo: 0, hi: _n)]
        : unknown;
  }

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// final color = ScaleThreshold(
  ///   range: ["red", "white", "green"],
  /// )..domain = [0, 1];
  ///
  /// color.domain; // [0, 1]
  /// ```
  ///
  /// The values must be in ascending order or the behavior of the scale is
  /// undefined. The values are typically numbers, but any naturally ordered
  /// values (such as strings) will work; a threshold scale can be used to
  /// encode any type that is ordered. If the number of values in the scale’s
  /// range is *n* + 1, the number of values in the scale’s domain must be *n*.
  /// If there are fewer than *n* elements in the domain, the additional values
  /// in the range are ignored. If there are more than *n* elements in the
  /// domain, the scale may return null for some inputs.
  @override
  get domain => _domain.sublist(0);
  @override
  set domain(domain) {
    _domain = domain;
    _n = math.min(_domain.length, _range.length - 1);
  }

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// final color = ScaleThreshold(…)..range = ["red", "white", "green"];
  /// ```
  ///
  /// If the number of values in the scale’s domain is *n*, the number of values
  /// in the scale’s range must be *n* + 1. If there are fewer than *n* + 1
  /// elements in the range, the scale may return null for some inputs. If there
  /// are more than *n* + 1 elements in the range, the additional values are
  /// ignored. The elements in the given list need not be numbers; any value or
  /// type will work.
  @override
  get range => _range.sublist(0);
  @override
  set range(range) {
    _range = range;
    _n = math.min(_domain.length, _range.length - 1);
  }

  /// Returns the extent of values in the [domain] (*x0*, *x1*) for the
  /// corresponding value in the [range], representing the inverse mapping from
  /// range to domain.
  ///
  /// ```dart
  /// final color = ScaleThreshold(
  ///   domain: [0, 1],
  ///   range: ["red", "white", "green"],
  /// );
  /// color.invertExtent("red"); // [null, 0]
  /// color.invertExtent("white"); // [0, 1]
  /// color.invertExtent("green"); // [1, null]
  /// ```
  ///
  /// This method is useful for interaction, say to determine the value in the
  /// domain that corresponds to the pixel location under the mouse. The extent
  /// below the lowest threshold is null (unbounded), as is the extent above the
  /// highest threshold.
  (X?, X?) invertExtent(Y y) {
    var i = _range.indexOf(y);
    return i < 0 || _domain.isEmpty
        ? (null, null)
        : (
            i == 0 ? null : _domain[i - 1],
            i == _domain.length ? null : _domain[i]
          );
  }

  /// Returns an exact copy of this scale.
  ///
  /// ```dart
  /// final c1 = ScaleThreshold(
  ///   domain: [0, 1],
  ///   range: schemeBlues[5],
  /// );
  /// final c2 = c1.copy();
  /// ```
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScaleThreshold<X, Y> copy() {
    return ScaleThreshold(domain: _domain, range: _range)..unknown = unknown;
  }
}
