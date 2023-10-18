import 'dart:math' as math;

import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'scale.dart';

num Function(num) _transformPow(num exponent) {
  return (x) {
    return x < 0 ? -math.pow(-x, exponent) : math.pow(x, exponent);
  };
}

num _transformSqrt(num x) {
  return x < 0 ? -math.sqrt(-x) : math.sqrt(x);
}

num _transformSquare(num x) {
  return x < 0 ? -x * x : x * x;
}

base mixin Powish<Y> on Scale<num, Y>, Linearish<Y> {
  num _exponent = 1;

  void _rescale() {
    _exponent == 1
        ? transform(identity, identity)
        : _exponent == 0.5
            ? transform(_transformSqrt, _transformSquare)
            : transform(_transformPow(_exponent), _transformPow(1 / exponent));
  }

  /// The scale's exponent.
  ///
  /// ```dart
  /// final x = ScalePow(
  ///   domain: [0, 100],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// )..exponent = 2;
  /// ```
  ///
  /// x..exponent; // 2
  ///
  /// Defaults to 1, which means that, by default, the pow scale is effectively
  /// a [ScaleLinear].
  num get exponent => _exponent;
  set exponent(num exponent) {
    _exponent = exponent;
    _rescale();
  }
}

extension InitPowish<Y> on Powish<Y> {
  void initPowish() {
    transform(identity, identity);
  }
}

/// Power (“pow”) scales are similar to
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html),
/// except an exponential transform is applied to the input domain value before
/// the output range value is computed.
///
/// Each range value *y* can be expressed as a function of the domain value *x:
/// y = mx^k + b*, where *k* is the exponent value. Power scales also support
/// negative domain values, in which case the input value and the resulting
/// output value are multiplied by -1.
///
/// {@category Pow scales}
final class ScalePow<Y> extends ScaleContinuousBase<num, Y>
    with Linearish<Y>, Powish<Y> {
  /// Constructs a new pow scale with the specified [domain], [range] and
  /// [interpolate], the [exponent] 1, and [clamp]ing disabled.
  ///
  /// ```dart
  /// final x = ScalePow(
  ///   domain: [0, 100],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// )..exponent = 2;
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0, 1\].
  ScalePow(
      {super.domain = const [0, 1],
      required super.range,
      required super.interpolate}) {
    initPowish();
    numberize(identity, identity);
  }

  /// Constructs a new pow scale with the specified [domain], [range] and
  /// [interpolate], the [exponent] 0.5, and [clamp]ing disabled.
  ///
  /// ```dart
  /// final x = ScalePow(
  ///   domain: [0, 100],
  ///   range: ["red", "blue"],
  ///   interpolate: interpolateRgb,
  /// )..exponent = 2;
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[0, 1\]. This is a
  /// convenience method equivalent to `ScalePow(…)..exponent = 0.5`.
  ScalePow.sqrt(
      {super.domain = const [0, 1],
      required super.range,
      required super.interpolate}) {
    exponent = 0.5;
    numberize(identity, identity);
  }

  @override
  ScalePow<Y> copy() => assign(
      ScalePow(domain: domain, range: range, interpolate: this.interpolate),
      this)
    ..exponent = exponent;

  /*static ScalePow<num> sqrt(
      {List<num> domain = const [0, 1],
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScalePow(domain: domain, range: range, interpolate: interpolate)
      ..exponent = 0.5;
  }*/

  static ScalePow<num> number(
      {List<num> domain = const [0, 1],
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScalePow(domain: domain, range: range, interpolate: interpolate);
  }

  static ScalePow<Object?> dynamic(
      {List<num> domain = const [0, 1],
      List<Object?> range = const <num>[0, 1],
      Interpolate<Object?> interpolate = interpolate}) {
    return ScalePow(domain: domain, range: range, interpolate: interpolate);
  }
}
