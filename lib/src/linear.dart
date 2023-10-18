import 'package:d4_format/d4_format.dart';
import 'package:d4_array/d4_array.dart' as d4_array;
import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'scale.dart';
import 'tick_format.dart' as d4_scale;

base mixin Linearish<Y> implements Scale<num, Y> {
  /// Returns approximately count representative values from the scale’s
  /// [domain].
  ///
  /// ```dart
  /// final x = ScaleLinear(
  ///   domain: [10, 100],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// );
  /// x.ticks(); // [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
  /// ```
  ///
  /// If [count] is not specified, it defaults to 10. The returned tick values
  /// are uniformly spaced, have human-readable values (such as multiples of
  /// powers of 10), and are guaranteed to be within the extent of the domain.
  /// Ticks are often used to display reference lines, or tick marks, in
  /// conjunction with the visualized data. The specified [count] is only a
  /// hint; the scale may return more or fewer values depending on the domain.
  /// See also [d4_array.ticks].
  List<num> ticks([num count = 10]) {
    var d = domain;
    return d4_array.ticks(d[0], d[d.length - 1], count);
  }

  /// Returns a
  /// [number format](https://pub.dev/documentation/d4_format/latest/d4_format/d4_format-library.html)
  /// function suitable for displaying a tick value, automatically computing the
  /// appropriate precision based on the fixed interval between tick values.
  ///
  /// The specified [count] should have the same value as the count that is used
  /// to generate the [ticks].
  ///
  /// ```dart
  /// final x = ScaleLinear(
  ///   domain: [0.1, 1],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// );
  /// final f = x.tickFormat();
  /// f(0.1); // "0.1"
  /// f(1); // "1.0"
  /// ```
  ///
  /// An optional specifier allows a custom format (see [FormatLocale]) where
  /// the precision of the format is automatically set by the scale as
  /// appropriate for the tick interval. For example, to format percentage
  /// change, you might say:
  ///
  /// ```dart
  /// var x = ScaleLinear(
  ///   domain: [-1, 1],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// );
  ///
  /// var ticks = x.ticks(5),
  ///     tickFormat = x.tickFormat(5, "+%");
  ///
  /// ticks.map(tickFormat); // ["-100%", "-50%", "+0%", "+50%", "+100%"]
  /// ```
  ///
  /// If [specifier] uses the format type `s`, the scale will return a SI-prefix
  /// format (see [formatPrefix]) based on the largest value in the domain. If
  /// the [specifier] already specifies a precision, this method is equivalent
  /// to [FormatLocale.format].
  ///
  /// See also [d4_scale.tickFormat].
  String Function(num) tickFormat([num count = 10, String? specifier]) {
    var d = domain;
    return d4_scale.tickFormat(d[0], d[d.length - 1], count, specifier);
  }

  /// Extends the [domain] so that it starts and ends on nice round values.
  ///
  /// ```dart
  /// final x = ScaleLinear(
  ///   domain: [0.241079, 0.969679],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// )..nice();
  /// x.domain; // [0.2, 1]
  /// ```
  ///
  /// This method typically modifies the scale’s domain, and may only extend the
  /// bounds to the nearest round value. Nicing is useful if the domain is
  /// computed from data, say using [d4_array.extent], and may be irregular. If
  /// the domain has more than two values, nicing the domain only affects the
  /// first and last value. See also [d4_array.tickStep].
  ///
  /// An optional tick [count] argument allows greater control over the step
  /// size used to extend the bounds, guaranteeing that the returned [ticks]
  /// will exactly cover the domain.
  ///
  /// ```dart
  /// final x = ScaleLinear(
  ///   domain: [0.241079, 0.969679],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// )..nice(40);
  /// x.domain; // [0.24, 0.98]
  /// ```
  ///
  /// Nicing a scale only modifies the current domain; it does not automatically
  /// nice domains that are subsequently set. You must re-nice the scale after
  /// setting the new domain, if desired.
  void nice([num count = 10]) {
    var d = domain;
    var i0 = 0;
    var i1 = d.length - 1;
    var start = d[i0];
    var stop = d[i1];
    num? prestep;
    num step;
    var maxIter = 10;

    if (stop < start) {
      step = start;
      start = stop;
      stop = step;
      step = i0;
      i0 = i1;
      i1 = step as int;
    }

    while (maxIter-- > 0) {
      step = d4_array.tickIncrement(start, stop, count);
      //if (!step.isFinite) return;
      if (step == prestep) {
        d[i0] = start;
        d[i1] = stop;
        domain = d;
        break;
      } else if (step > 0) {
        start = (start / step).floorToDouble() * step;
        stop = (stop / step).ceilToDouble() * step;
      } else if (step < 0) {
        start = (start * step).ceilToDouble() / step;
        stop = (stop * step).floorToDouble() / step;
      } else {
        break;
      }
      prestep = step;
    }
  }
}

extension InitLinearish<Y> on Linearish<Y> {
  void initLinearish() {
    transform(identity, identity);
  }
}

// A scale that maps a continuous quantitative input domain to a continuous
// output range using a linear transformation.

/// Linear scales map a continuous, quantitative input [domain] to a continuous
/// output [range] using a linear transformation (translate and scale).
///
/// If the range is also numeric, the mapping may be inverted (see
/// [ScaleContinuousNumberExtension.invert]). Linear scales are a good default
/// choice for continuous quantitative data because they preserve proportional
/// differences. Each range value *y* can be expressed as a function of the
/// domain value *x*: *y* = *mx* + *b*.
///
/// {@category Linear scales}
final class ScaleLinear<Y> extends ScaleContinuousBase<num, Y>
    with Linearish<Y> {
  /// Constructs a new linear scale with the specified [domain], [range] and
  /// [interpolate], and [clamp]ing disabled.
  ///
  /// ```dart
  /// ScaleLinear(
  ///   domain: [0, 100],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0, 1\].
  ///
  /// ```dart
  /// ScaleLinear(
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// ); // default domain of [0, 1]
  /// ```
  ScaleLinear(
      {super.domain = const [0, 1],
      required super.range,
      required super.interpolate}) {
    initLinearish();
    numberize(identity, identity);
  }

  @override
  ScaleLinear<Y> copy() => assign(
      ScaleLinear<Y>(
          domain: domain, range: range, interpolate: this.interpolate),
      this);

  static ScaleLinear<num> number(
      {List<num> domain = const [0, 1],
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScaleLinear(domain: domain, range: range, interpolate: interpolate);
  }

  static ScaleLinear<Object?> dynamic(
      {List<num> domain = const [0, 1],
      List<Object?> range = const <num>[0, 1],
      Interpolate<Object?> interpolate = interpolate}) {
    return ScaleLinear(domain: domain, range: range, interpolate: interpolate);
  }
}
