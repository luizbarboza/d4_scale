import 'dart:math';

import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'log.dart';
import 'scale.dart';

num Function(num) _transformSymlog(num c) {
  return (x) {
    return x.sign * log(1 + (x / c).abs());
  };
}

num Function(num) _transformSymexp(num c) {
  return (x) {
    return x.sign * (exp(x.abs()) - 1) * c;
  };
}

base mixin Symlogish<Y> on Scale<num, Y>, Linearish<Y> {
  num _c = 1;

  set constant(num constant) {
    _c = constant;
    transform(_transformSymlog(_c), _transformSymexp(_c));
  }

  num get constant => _c;
}

extension InitSymlogish<Y> on Symlogish<Y> {
  void initSymlogish() {
    transform(_transformSymlog(_c), _transformSymexp(_c));
  }
}

/// See
/// [A bi-symmetric log transformation for wide-range data](https://www.researchgate.net/profile/John_Webber4/publication/233967063_A_bi-symmetric_log_transformation_for_wide-range_data/links/0fcfd50d791c85082e000000.pdf)
/// by Webber for details. Unlike a [ScaleLog], a symlog scale domain can
/// include zero.
///
/// {@category Symlog scales}
final class ScaleSymlog<Y> extends ScaleContinuousBase<num, Y>
    with Linearish<Y>, Symlogish<Y> {
  /// Constructs a new continuous scale with the specified [domain], [range] and
  /// [interpolate], the [constant] 1, and [clamp]ing disabled.
  ///
  /// ```dart
  /// final x = ScaleSymlog(
  ///   domain: [0, 100],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumer
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
  ScaleSymlog(
      {super.domain = const [0, 1],
      required super.range,
      required super.interpolate}) {
    initSymlogish();
    numberize(identity, identity);
  }

  @override
  ScaleSymlog<Y> copy() => assign(
      ScaleSymlog<Y>(
          domain: domain, range: range, interpolate: this.interpolate),
      this)
    ..constant = constant;

  static ScaleSymlog<num> number(
      {List<num> domain = const [0, 1],
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScaleSymlog(domain: domain, range: range, interpolate: interpolate);
  }

  static ScaleSymlog<Object?> dynamic(
      {List<num> domain = const [0, 1],
      List<Object?> range = const <num>[0, 1],
      Interpolate<Object?> interpolate = interpolate}) {
    return ScaleSymlog(domain: domain, range: range, interpolate: interpolate);
  }
}
