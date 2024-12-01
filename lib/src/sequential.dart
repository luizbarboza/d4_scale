import 'dart:math';

import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'log.dart';
import 'pow.dart';
import 'scale.dart';
import 'sequential_quantile.dart';
import 'symlog.dart';

abstract base class ScaleSequentialBase<Y> implements Scale<num, Y> {
  num _x0 = 0, _x1 = 1;
  late num _t0, _t1, _k10;
  late num Function(num) _transform;

  /// The scale’s interpolator.
  ///
  /// ```dart
  /// final color = ScaleSequential(…)..interpolator = interpolateBlues;
  /// ```
  Y Function(num) interpolator;

  bool clamp = false;
  Y? unknown;

  ScaleSequentialBase({required this.interpolator});

  @override
  call(x) {
    return x == null || x.isNaN
        ? unknown
        : interpolator(_k10 == 0
            ? 0.5
            : (x = (_transform(x) - _t0) * _k10, clamp ? max(0, min(1, x)) : x)
                .$2);
  }

  @override
  set domain(domain) {
    _x0 = domain[0];
    _x1 = domain[1];
    _t0 = _transform(_x0);
    _t1 = _transform(_x1);
    _k10 = _t0 == _t1 ? 0 : 1 / (_t1 - _t0);
  }

  @override
  get domain {
    return [_x0, _x1];
  }

  /// See [ScaleLinear.range].
  ///
  /// When the [range] is specified, the given two-element list is converted to
  /// an interpolation function using [interpolate].
  ///
  /// ```dart
  /// final color = ScaleSequential(…)..range = ["red", "blue"];
  /// ```
  ///
  /// The above is equivalent to:
  ///
  /// ```dart
  /// final color = ScaleSequential(interpolator: interpolate("red", "blue"));
  /// ```
  @override
  get range => [interpolator(0), interpolator(1)];
  @override
  set range(range) {
    final r0 = range[0], r1 = range[1];
    interpolator = interpolate(r0, r1) as Y Function(num);
  }
}

/// Adds [rangeRound] method to sequential scales with numeric range.
extension ScaleSequentialNumberExtension on ScaleSequential<num> {
  /// See [ScaleContinuousNumberExtension.rangeRound].
  ///
  /// Implicitly uses [interpolateRound] as the interpolator.
  void rangeRound(List<num> range) {
    final r0 = range[0], r1 = range[1];
    interpolator = interpolateRound(r0, r1);
  }
}

S assign<Y, S extends ScaleSequential<Y>>(S target, ScaleSequential<Y> source) {
  return target
    ..domain = source.domain
    ..interpolator = source.interpolator
    ..clamp = source.clamp
    ..unknown = source.unknown;
}

/// Sequential scales are similar to
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html),
/// but the input domain and output range always have exactly three elements.
///
/// Sequential scales are typically used for a color encoding; see also
/// [d4_scale_chromatic](hhttps://pub.dev/documentation/d4_scale_chromatic/latest/d4_scale_chromatic/d4_scale_chromatic-library.html).
/// These scales do not expose [ScaleContinuousNumberExtension.invert] and
/// [ScaleLinear.interpolate] methods. There are also [ScaleSequentialLog],
/// [ScaleSequentialPow], [ScaleSequentialSymlog], and [ScaleSequentialQuantile]
/// variants of sequential scales.
///
/// {@category Sequential scales}
final class ScaleSequential<Y> extends ScaleSequentialBase<Y>
    with Linearish<Y> {
  /// Constructs a new sequential scale with the specified [domain] and
  /// [interpolator] function.
  ///
  /// ```dart
  /// final color = ScaleSequential(
  ///   domain: [0, 100],
  ///   interpolator: interpolateBlues,
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0, 1\].
  ///
  /// ```dart
  /// final color = ScaleSequential(interpolator: interpolateBlues);
  /// ```
  ///
  /// When the scale is applied, the interpolator will be invoked with a value
  /// typically in the range \[0, 1\], where 0 represents the minimum value and
  /// 1 represents the maximum value. For example, to implement the ill-advised
  /// angry rainbow scale (please use
  /// [interpolateRainbow](https://pub.dev/documentation/d4_scale_chromatic/latest/d4_scale_chromatic/interpolateRainbow.html)
  /// instead):
  ///
  /// ```dart
  /// final rainbow = ScaleSequential(interpolator: (t) => Hsl(t * 360, 1, 0.5).toString());
  /// ```
  ///
  /// A sequential scale’s domain must be numeric and must contain exactly two
  /// values.
  ScaleSequential({List<num>? domain, required super.interpolator}) {
    initLinearish();
    if (domain != null) this.domain = domain;
  }

  @override
  ScaleSequential<Y> copy() => assign(
      ScaleSequential<Y>(domain: domain, interpolator: interpolator), this);

  static ScaleSequential<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }

  static ScaleSequential<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }
}

/// A sequential scale with a logarithmic transform, analogous to [ScaleLog].
///
/// {@category Sequential scales}
final class ScaleSequentialLog<Y> extends ScaleSequential<Y> with Loggish<Y> {
  /// Returns a new sequential scale with a logarithmic transform, analogous to
  /// [ScaleLog].
  ScaleSequentialLog(
      {super.domain = const [1, 10], required super.interpolator}) {
    initLoggish();
  }

  @override
  ScaleSequentialLog<Y> copy() => assign(
      ScaleSequentialLog<Y>(domain: domain, interpolator: interpolator), this)
    ..base = base;

  static ScaleSequential<num> number(
      {List<num>? domain = const [1, 10],
      Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }

  static ScaleSequential<Object?> dynamic(
      {List<num>? domain = const [1, 10],
      Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }
}

/// A sequential scale with a logarithmic transform, analogous to a
/// [ScaleSymlog].
///
/// {@category Sequential scales}
final class ScaleSequentialSymlog<Y> extends ScaleSequential<Y>
    with Symlogish<Y> {
  /// Returns a new sequential scale with a logarithmic transform, analogous to
  /// a [ScaleSymlog].
  ScaleSequentialSymlog({super.domain, required super.interpolator}) {
    initSymlogish();
  }

  @override
  ScaleSequentialSymlog<Y> copy() => assign(
      ScaleSequentialSymlog<Y>(domain: domain, interpolator: interpolator),
      this)
    ..constant = constant;

  static ScaleSequential<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }

  static ScaleSequential<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }
}

/// A sequential scale with an exponential transform, analogous to a [ScalePow].
///
/// {@category Sequential scales}
final class ScaleSequentialPow<Y> extends ScaleSequential<Y> with Powish<Y> {
  /// Returns a new sequential scale with an exponential transform, analogous to
  /// a [ScalePow].
  ScaleSequentialPow({super.domain, required super.interpolator}) {
    initPowish();
  }

  /// Returns a new sequential scale with a square-root transform, analogous to
  /// a [ScalePow.sqrt].
  ScaleSequentialPow.sqrt({super.domain, required super.interpolator}) {
    exponent = 0.5;
    initPowish();
  }

  @override
  ScaleSequentialPow<Y> copy() => assign(
      ScaleSequentialPow<Y>(domain: domain, interpolator: interpolator), this)
    ..exponent = exponent;

  static ScaleSequential<num> number(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }

  static ScaleSequential<Object?> dynamic(
      {List<num>? domain, Interpolator<num> interpolator = identity}) {
    return ScaleSequential(domain: domain, interpolator: interpolator);
  }
}

extension ScaleSequentialTransform<Y> on ScaleSequentialBase<Y> {
  void transform(num Function(num) t) {
    _transform = t;
    _t0 = t(_x0);
    _t1 = t(_x1);
    _k10 = _t0 == _t1 ? 0 : 1 / (_t1 - _t0);
  }
}
