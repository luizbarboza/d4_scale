import 'dart:math';

import 'package:d4_array/d4_array.dart' as array;

import 'ordinal.dart';

/// Point scales are a variant of
/// [band scales](https://pub.dev/documentation/d4_scale/latest/topics/Band%20scales-topic.html)
/// with the bandwidth fixed to zero.
///
/// Point scales are typically used for scatterplots with an ordinal or
/// categorical dimension.
///
/// {@category Point scales}
final class ScalePoint<X> extends ScaleOrdinal<X, num> {
  num _r0 = 0, _r1 = 1;
  late num _step, _bandwidth;
  bool _round = false;
  num _paddingInner = 1, _paddingOuter = 0, _align = 0.5;

  /// Constructs a new point scale with the specified [domain] and [range], no
  /// [padding], no [round]ing and center [align]ment. If domain is not
  /// specified, it defaults to the empty domain. If range is not specified, it
  /// defaults to the unit range \[0, 1\].
  ScalePoint({List<X>? domain, List<num>? range}) {
    super.implicit = false;
    _rescale();
    if (range != null) this.range = range;
    if (domain != null) this.domain = domain;
  }

  @override
  set implicit(bool _) {
    throw UnsupportedError(
        "Band scales do not allow implicit domain construction.");
  }

  void _rescale() {
    var n = super.domain.length,
        reverse = _r1 < _r0,
        start = reverse ? _r1 : _r0,
        stop = reverse ? _r0 : _r1;
    _step = (stop - start) / max(1, n - _paddingInner + _paddingOuter * 2);
    if (_round) _step = _step.floor();
    start += (stop - start - _step * (n - _paddingInner)) * _align;
    _bandwidth = _step * (1 - _paddingInner);
    if (_round) {
      start = start.round();
      _bandwidth = _bandwidth.round();
    }
    var values = array.range(stop: n).map((i) {
      return start + _step * i;
    }).toList();
    super.range = reverse ? array.reverse(values) : values;
  }

  /// Given a value in the input [domain], returns the corresponding point
  /// derived from the output range.
  ///
  /// ```dart
  /// final x = ScalePoint(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// );
  /// x("a"); // 0
  /// x("b"); // 480
  /// x("c"); // 960
  /// x("d"); // null
  /// ```
  ///
  /// If the given value is not in the scale’s domain, returns the [unknown]
  /// value.
  @override
  call(x);

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// final x = ScalPoint(
  ///   range: [0, 960],
  /// )..domain = ["a", "b", "c", "d", "e", "f"];
  /// ```
  ///
  /// The first element in [domain] will be mapped to the first point, the
  /// second domain value to the second band, and so on.
  @override
  set domain(domain) {
    super.domain = domain;
    _rescale();
  }

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// final x = ScalePoint()..range = [0, 960];
  /// ```
  ///
  /// Defaults to \[0, 1\].
  @override
  get range => [_r0, _r1];
  @override
  set range(range) {
    _r0 = range[0];
    _r1 = range[1];
    _rescale();
  }

  /// Sets the scale’s [range] to the specified two-element list of numbers
  /// while also enabling [round]ing.
  ///
  /// ```dart
  /// final x = ScalePoint()..rangeRound([0, 960]);
  /// ```
  ///
  /// This is a convenience method equivalent to:
  ///
  /// ```dart
  /// band
  ///   ..range = range
  ///   ..round = true;
  /// ```
  ///
  /// Rounding is sometimes useful for avoiding antialiasing artifacts, though
  /// also consider the
  /// [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering)
  /// “crispEdges” styles.
  void rangeRound(List<num> range) {
    _r0 = range[0];
    _r1 = range[1];
    _round = true;
    _rescale();
  }

  /// Whether or not the scale currently rounds the edges of the bands.
  ///
  /// ```dart
  /// final x = ScalePoint(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..round = false;
  /// ```
  ///
  /// If rounding is enabled, the position of each point will be integers.
  /// Rounding is sometimes useful for avoiding antialiasing artifacts, though
  /// also consider the
  /// [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering)
  /// “crispEdges” styles. Note that if the width of the domain is not a
  /// multiple of the cardinality of the range, there may be leftover unused
  /// space, even without padding! Use [align] to specify how the leftover space
  /// is distributed.
  bool get round => _round;
  set round(bool round) {
    _round = round;
    _rescale();
  }

  /// The amount of blank space, in terms of multiples of the [step], to
  /// reserve before the first point and after the last point.
  ///
  /// ```dart
  /// final x = ScalePoint(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..padding = 0.1;
  /// ```
  ///
  /// Equivalent to [ScaleBand.paddingOuter].
  num get padding => _paddingOuter;
  set padding(num padding) {
    _paddingOuter = padding;
    _rescale();
  }

  /// How any leftover unused space in the range is distributed.
  ///
  /// ```dart
  /// final x = ScalePoint(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..align = 0.5;
  /// ```
  ///
  /// Must be in the range \[0, 1\]. A value of 0.5 indicates that the leftover
  /// space should be equally distributed before the first point and after the
  /// last point; i.e., the points should be centered within the range. A value
  /// of 0 or 1 may be used to shift the points to one side, say to position
  /// them adjacent to an axis.
  num get align => _align;
  set align(num align) {
    _align = max(0, min(1, align));
    _rescale();
  }

  /// Returns zero.
  num get bandwidth => _bandwidth;

  /// Returns the distance between adjacent points.
  num get step => _step;

  /// Returns an exact copy of this scale.
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScalePoint<X> copy() {
    return ScalePoint(domain: super.domain, range: [_r0, _r1])..round = round;
  }
}

/// Band scales are like
/// [ordinal scales](https://pub.dev/documentation/d4_scale/latest/topics/Ordinal%20scales-topic.html)
/// except the output range is continuous and numeric.
///
/// The scale divides the continuous range into uniform bands. Band scales are
/// typically used for bar charts with an ordinal or categorical dimension.
///
/// <img src="https://raw.githubusercontent.com/d3/d3-scale/master/img/band.png" width="751" height="238" alt="band">
///
/// {@category Band scales}
final class ScaleBand<X> extends ScalePoint<X> {
  /// Constructs a new band scale with the specified [domain] and [range], no
  /// [padding], no [round]ing and center [align]ment.
  ///
  /// If [domain] is not specified, it defaults to the empty domain. If [range]
  /// is not specified, it defaults to the unit range \[0, 1\].
  ScaleBand({super.domain, super.range}) {
    paddingInner = 0;
  }

  /// Given a value in the input [domain], returns the start of the
  /// corresponding band derived from the output [range].
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// );
  /// x("a"); // 0
  /// x("b"); // 320
  /// x("c"); // 640
  /// x("d"); // null
  /// ```
  ///
  /// If the given value is not in the scale’s domain, returns the [unknown]
  /// value.
  @override
  call(x);

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   range: [0, 960],
  /// )..domain = ["a", "b", "c", "d", "e", "f"];
  /// ```
  ///
  /// The first element in [domain] will be mapped to the first band, the second
  /// domain value to the second band, and so on.
  @override
  get domain;

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// final x = ScaleBand()..range = [0, 960];
  /// ```
  ///
  /// Defaults to \[0, 1\].
  @override
  get range;

  /// Sets the scale’s [range] to the specified two-element list of numbers
  /// while also enabling [round]ing.
  ///
  /// ```dart
  /// final x = ScaleBand()..rangeRound([0, 960]);
  /// ```
  ///
  /// This is a convenience method equivalent to:
  ///
  /// ```dart
  /// band
  ///   ..range = range
  ///   ..round = true;
  /// ```
  ///
  /// Rounding is sometimes useful for avoiding antialiasing artifacts, though
  /// also consider the
  /// [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering)
  /// “crispEdges” styles.
  @override
  void rangeRound(List<num> range);

  /// Whether or not the scale currently rounds the edges of the bands.
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..round = false;
  /// ```
  ///
  /// If rounding is enabled, the start and stop of each band will be integers.
  /// Rounding is sometimes useful for avoiding antialiasing artifacts, though
  /// also consider the
  /// [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering)
  /// “crispEdges” styles. Note that if the width of the domain is not a
  /// multiple of the cardinality of the range, there may be leftover unused
  /// space, even without padding! Use [align] to specify how the leftover space
  /// is distributed.
  @override
  get round;

  /// The scale's [paddingInner] and [paddingOuter].
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..padding = 0.1;
  /// ```
  ///
  /// When setting the padding, it defines both the inner and outer paddings.
  /// Getting the padding is equivalent to obtaining the inner padding.
  @override
  num get padding => _paddingInner;
  @override
  set padding(num padding) {
    _paddingInner = min(1, _paddingOuter = padding);
    _rescale();
  }

  /// The proportion of the range that is reserved for blank space between
  /// bands.
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..paddingInner = 0.1;
  /// ```
  ///
  /// Must be less than or equal to 1. A value of 0 means no blank space between
  /// bands, and a value of 1 means a [bandwidth] of zero.
  ///
  /// Defaults to 0.
  num get paddingInner => _paddingInner;
  set paddingInner(num paddingInner) {
    _paddingInner = min(1, paddingInner);
    _rescale();
  }

  /// The amount of blank space, in terms of multiples of the [step], to reserve
  /// before the first band and after the last band.
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..paddingOuter = 0.1;
  /// ```
  ///
  /// Typically in the range \[0, 1\].
  ///
  /// Defaults to 0.
  num get paddingOuter => _paddingOuter;
  set paddingOuter(num paddingOuter) {
    _paddingOuter = paddingOuter;
    _rescale();
  }

  /// How outer padding is distributed in the range.
  ///
  /// ```dart
  /// final x = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// )..align = 0.5;
  /// ```
  ///
  /// Must be in the range \[0, 1\]. A value of 0.5 indicates that the outer
  /// padding should be equally distributed before the first band and after the
  /// last band; i.e., the bands should be centered within the range. A value of
  /// 0 or 1 may be used to shift the bands to one side, say to position them
  /// adjacent to an axis. For more,
  /// [see this explainer](https://observablehq.com/@d3/band-align).
  @override
  get align;

  /// The width of each band.
  ///
  /// ```dart
  /// x.bandwidth // 50.8235294117647
  /// ```
  @override
  get _bandwidth;

  /// The distance between the starts of adjacent bands.
  ///
  /// ```dart
  /// x.step // 63.529411764705884
  /// ```
  @override
  get _step;

  /// Returns an exact copy of this scale.
  ///
  /// ```dart
  /// final x1 = ScaleBand(
  ///   domain: ["a", "b", "c"],
  ///   range: [0, 960],
  /// );
  /// final x2 = x1.copy();
  /// ```
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScaleBand<X> copy() {
    return ScaleBand(domain: super.domain, range: [_r0, _r1])
      ..round = round
      ..paddingInner = _paddingInner
      ..paddingOuter = _paddingOuter
      ..align = _align;
  }
}
