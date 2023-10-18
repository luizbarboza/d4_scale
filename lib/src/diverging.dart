import 'dart:math';

import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'log.dart';
import 'pow.dart';
import 'scale.dart';
import 'symlog.dart';

abstract base class ScaleDivergingBase<Y> implements Scale<num, Y> {
  num _x0 = 0, _x1 = 0.5, _x2 = 1;
  late num _s;
  late num _t0, _t1, _t2, _k10, _k21;
  late num Function(num) _transform;

  /// The scale’s interpolator.
  ///
  /// ```dart
  /// final color = ScaleDiverging(…)..interpolator = interpolateRdBu;
  /// ```
  Y Function(num) interpolator;

  bool clamp = false;
  Y? unknown;

  ScaleDivergingBase({required this.interpolator});

  @override
  call(x) {
    num x0;
    return x == null || (x0 = _transform(x)).isNaN
        ? unknown
        : (
            x0 = 0.5 +
                ((x0 = _transform(x)) - _t1) *
                    (_s * x0 < _s * _t1 ? _k10 : _k21),
            interpolator(clamp ? max(0, min(1, x0)) : x0)
          ).$2;
  }

  @override
  get domain => [_x0, _x1, _x2];
  @override
  set domain(domain) {
    _x0 = domain[0];
    _x1 = domain[1];
    _x2 = domain[2];
    _t0 = _transform(_x0);
    _t1 = _transform(_x1);
    _t2 = _transform(_x2);
    _k10 = _t0 == _t1 ? 0 : 0.5 / (_t1 - _t0);
    _k21 = _t1 == _t2 ? 0 : 0.5 / (_t2 - _t1);
    _s = _t1 < _t0 ? -1 : 1;
  }

  /// See [ScaleLinear.range].
  ///
  /// When the [range] is specified, the given two-element list is converted to
  /// an interpolation function using [piecewise].
  ///
  /// ```dart
  /// final color = ScaleDiverging(…)..range = ["red", "white", "blue"];
  /// ```
  ///
  /// The above is equivalent to:
  ///
  /// ```dart
  /// final color = ScaleSequential(interpolator: piecewise("red", "white", "blue"));
  /// ```
  @override
  get range => [interpolator(0), interpolator(0.5), interpolator(1)];
  @override
  set range(range) {
    final r0 = range[0], r1 = range[1], r2 = range[2];
    interpolator = piecewise([r0, r1, r2], interpolate) as Y Function(num);
  }
}

/// Adds [rangeRound] method to diverging scales with numeric range.
extension ScaleDivergingNumberExtension on ScaleDiverging<num> {
  /// See [ScaleContinuousNumberExtension.rangeRound].
  ///
  /// Implicitly uses [interpolateRound] as the interpolator.
  void rangeRound(List<num> range) {
    final r0 = range[0], r1 = range[1], r2 = range[2];
    interpolator =
        piecewise([r0, r1, r2], interpolateRound) as num Function(num);
  }
}

S assign<Y, S extends ScaleDiverging<Y>>(S target, ScaleDiverging<Y> source) {
  return target
    ..domain = source.domain
    ..interpolator = source.interpolator
    ..clamp = source.clamp
    ..unknown = source.unknown;
}

/// Diverging scales are similar to
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html),
/// but the input domain and output range always have exactly three elements.
///
/// Diverging scales are typically used for a color encoding; see
/// [d4_scale_chromatic](https://pub.dev/documentation/d4_scale_chromatic/latest/).
/// These scales do not expose [ScaleContinuousNumberExtension.invert] and
/// [ScaleLinear.interpolate] methods. There are also [ScaleDivergingLog],
/// [ScaleDivergingPow], and [ScaleDivergingSymlog] variants of diverging
/// scales.
///
/// {@category Diverging scales}
final class ScaleDiverging<Y> extends ScaleDivergingBase<Y> with Linearish<Y> {
  /// Constructs a new diverging scale with the specified [domain] and
  /// [interpolator] function.
  ///
  /// ```dart
  /// final color = ScaleDiverging(
  ///   domain: [-1, 0, 1],
  ///   interpolator: interpolateRdBu,
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0, 0.5, 1\].
  ///
  /// ```dart
  /// final color = ScaleDiverging(interpolator: interpolateRdBu);
  /// ```
  ///
  /// When the scale is applied, the interpolator will be invoked with a value
  /// typically in the range \[0, 1\], where 0 represents the extreme negative
  /// value, 0.5 represents the neutral value, and 1 represents the extreme
  /// positive value.
  ///
  /// A diverging scale’s domain must be numeric and must contain exactly three
  /// values.
  ScaleDiverging({List<num>? domain, required super.interpolator}) {
    initLinearish();
    if (domain != null) this.domain = domain;
  }

  @override
  ScaleDiverging<Y> copy() => assign(
      ScaleDiverging<Y>(domain: domain, interpolator: interpolator), this);

  static ScaleDiverging<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDiverging(domain: domain, interpolator: interpolator);
  }

  static ScaleDiverging<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDiverging(domain: domain, interpolator: interpolator);
  }
}

/// A diverging scale with a logarithmic transform, analogous to [ScaleLog].
///
/// {@category Diverging scales}
final class ScaleDivergingLog<Y> extends ScaleDiverging<Y> with Loggish<Y> {
  /// Returns a new diverging scale with a logarithmic transform, analogous to
  /// [ScaleLog].
  ScaleDivergingLog(
      {super.domain = const [0.1, 1, 10], required super.interpolator}) {
    initLoggish();
  }

  @override
  ScaleDivergingLog<Y> copy() => assign(
      ScaleDivergingLog<Y>(domain: domain, interpolator: interpolator), this)
    ..base = base;

  static ScaleDivergingLog<num> number(
      {List<num>? domain = const [0.1, 1, 10],
      Interpolator<num> interpolator = identity}) {
    return ScaleDivergingLog(domain: domain, interpolator: interpolator);
  }

  static ScaleDivergingLog<Object?> dynamic(
      {List<num>? domain = const [0.1, 1, 10],
      Interpolator<num> interpolator = identity}) {
    return ScaleDivergingLog(domain: domain, interpolator: interpolator);
  }
}

/// A diverging scale with a logarithmic transform, analogous to a
/// [ScaleSymlog].
///
/// {@category Diverging scales}
final class ScaleDivergingSymlog<Y> extends ScaleDiverging<Y>
    with Symlogish<Y> {
  /// Returns a new diverging scale with a logarithmic transform, analogous to
  /// a [ScaleSymlog].
  ScaleDivergingSymlog({super.domain, required super.interpolator}) {
    initSymlogish();
  }

  @override
  ScaleDivergingSymlog<Y> copy() => assign(
      ScaleDivergingSymlog<Y>(domain: domain, interpolator: interpolator), this)
    ..constant = constant;

  static ScaleDivergingSymlog<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDivergingSymlog(domain: domain, interpolator: interpolator);
  }

  static ScaleDivergingSymlog<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDivergingSymlog(domain: domain, interpolator: interpolator);
  }
}

/// A diverging scale with an exponential transform, analogous to a [ScalePow].
///
/// {@category Diverging scales}
final class ScaleDivergingPow<Y> extends ScaleDiverging<Y> with Powish<Y> {
  /// Returns a new diverging scale with an exponential transform, analogous to
  /// a [ScalePow].
  ScaleDivergingPow({super.domain, required super.interpolator}) {
    initPowish();
  }

  /// Returns a new diverging scale with a square-root transform, analogous to
  /// a [ScalePow.sqrt].
  ScaleDivergingPow.sqrt({super.domain, required super.interpolator}) {
    exponent = 0.5;
    initPowish();
  }

  @override
  ScaleDivergingPow<Y> copy() => assign(
      ScaleDivergingPow<Y>(domain: domain, interpolator: interpolator), this)
    ..exponent = exponent;

  static ScaleDivergingPow<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDivergingPow(domain: domain, interpolator: interpolator);
  }

  static ScaleDivergingPow<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleDivergingPow(domain: domain, interpolator: interpolator);
  }
}

extension ScaleDivergingTransform<Y> on ScaleDivergingBase<Y> {
  void transform(num Function(num) t) {
    _transform = t;
    _t0 = t(_x0);
    _t1 = t(_x1);
    _t2 = t(_x2);
    _k10 = _t0 == _t1 ? 0 : 0.5 / (_t1 - _t0);
    _k21 = _t1 == _t2 ? 0 : 0.5 / (_t2 - _t1);
    _s = _t1 < _t0 ? -1 : 1;
  }
}
