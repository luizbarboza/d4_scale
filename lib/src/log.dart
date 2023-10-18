import 'dart:math';

import 'package:d4_array/d4_array.dart' as array;
import 'package:d4_format/d4_format.dart';
import 'package:d4_interpolate/d4_interpolate.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'nice.dart';
import 'scale.dart';

double _transformLog(num x) {
  return log(x);
}

double _transformExp(num x) {
  return exp(x);
}

double _transformLogn(num x) {
  return -log(-x);
}

double _transformExpn(num x) {
  return -exp(-x);
}

num _pow10(num x) {
  return x.isFinite
      ? pow(10, x)
      : x < 0
          ? 0
          : x;
}

num Function(num) _powp(num base) {
  return base == 10
      ? _pow10
      : base == e
          ? exp
          : (x) => pow(base, x);
}

num Function(num) _logp(num base) {
  if (base == e) return log;
  base = base == 10
      ? ln10
      : base == 2
          ? ln2
          : log(base);
  return (x) => log(x) / base;
}

num Function(num) _reflect(num Function(num) f) {
  return (x) => -f(-x);
}

base mixin Loggish<Y> on Scale<num, Y> {
  num _base = 10;
  late num Function(num) _logs, _pows;

  void _rescale() {
    _logs = _logp(_base);
    _pows = _powp(_base);
    if (domain[0] < 0) {
      _logs = _reflect(_logs);
      _pows = _reflect(_pows);
      transform(_transformLogn, _transformExpn);
    } else {
      transform(_transformLog, _transformExp);
    }
  }

  /// The scale's base.
  ///
  /// ```dart
  /// final x = ScaleLog(
  ///   domain: [1, 1024],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// )..base = 2;
  /// ```
  ///
  /// Defaults to 10. Note that due to the nature of a logarithmic transform,
  /// the base does not affect the encoding of the scale; it only affects which
  /// [ticks] are chosen.
  num get base => _base;
  set base(num base) {
    _base = base;
    _rescale();
  }

  @override
  set domain(domain) {
    super.domain = domain;
    _rescale();
  }

  /// Like [ScaleLinear.ticks], but customized for a log scale.
  ///
  /// ```dart
  /// final x = ScaleLog(
  ///   domain: [1, 100],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber
  /// );
  /// final T = x.ticks(); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
  /// ```
  ///
  /// If the [base] is an integer, the returned ticks are uniformly spaced
  /// within each integer power of base; otherwise, one tick per power of base
  /// is returned. The returned ticks are guaranteed to be within the extent of
  /// the [domain]. If the orders of magnitude in the domain is greater than
  /// count, then at most one tick per power is returned. Otherwise, the tick
  /// values are unfiltered, but note that you can use [ScaleLog.tickFormat] to
  /// filter the display of tick labels. If count is not specified, it defaults
  /// to 10.
  List<num> ticks([num count = 10]) {
    final d = domain;
    var u = d[0];
    var v = d[d.length - 1];
    final r = v < u;

    if (r) ([u, v] = [v, u]);

    var i = _logs(u), j = _logs(v);
    num k, t;
    var z = <num>[];

    if (!((base % 1) != 0) && j - i < count) {
      i = i.floor();
      j = j.ceil();
      if (u > 0) {
        for (; i <= j; ++i) {
          for (k = 1; k < base; ++k) {
            t = i < 0 ? k / _pows(-i) : k * _pows(i);
            if (t < u) continue;
            if (t > v) break;
            z.add(t);
          }
        }
      } else {
        for (; i <= j; ++i) {
          for (k = base - 1; k >= 1; --k) {
            t = i > 0 ? k / _pows(-i) : k * _pows(i);
            if (t < u) continue;
            if (t > v) break;
            z.add(t);
          }
        }
      }
      if (z.length * 2 < count) z = array.ticks(u, v, count);
    } else {
      z = array.ticks(i, j, min(j - i, count)).map(_pows).toList();
    }
    return r ? array.reverse(z) : z;
  }

  /// Like [ScaleLinear.tickFormat], but customized for a log scale.
  ///
  /// The specified [count] typically has the same value as the count that is
  /// used to generate the tick values.
  ///
  /// ```dart
  /// final x = ScaleLog(
  ///   domain: [1, 100],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber
  /// );
  /// final T = x.ticks(); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, …]
  /// final f = x.tickFormat();
  /// T.map(f); // ["1", "2", "3", "4", "5", "", "", "", "", "10", …]
  /// ```
  ///
  /// If there are too many ticks, the formatter may return the empty string for
  /// some of the tick labels; however, note that the ticks are still shown to
  /// convey the logarithmic transform accurately. To disable filtering, specify
  /// a count of Infinity.
  ///
  /// When specifying a [count], you may also provide a format [specifier] or
  /// format function. For example, to get a tick formatter that will display 20
  /// ticks of a currency, say `log.tickFormat(20, "$,f")`. If the specifier
  /// does not have a defined precision, the precision will be set automatically
  /// by the scale, returning the appropriate format. This provides a convenient
  /// way of specifying a format whose precision will be automatically set by
  /// the scale.
  String Function(num) tickFormat([num count = 10, Object? specifier]) {
    specifier ??= base == 10 ? "s" : ",";
    if (specifier is! String Function(dynamic)) {
      if (base.remainder(1) == 0 &&
          (specifier = FormatSpecifier.parse(specifier as String)).precision ==
              null) (specifier as FormatSpecifier).trim = true;
      specifier = format(specifier.toString());
    }
    if (count == double.infinity) return specifier;
    final k = max(1, base * count / ticks().length); // TODO fast estimate?
    return (d) {
      var i = d / _pows((_logs(d)).round());
      if (i * base < base - 0.5) i *= base;
      return i <= k ? (specifier as String Function(dynamic))(d) : "";
    };
  }

  /// Like [ScaleLinear.nice], except extends the domain to integer powers of
  /// [base].
  ///
  /// ```dart
  /// final x = ScaleLog(
  ///   domain: [0.201479, 0.996679],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// )..nice();
  /// x.domain; // [0.1, 1]
  /// ```
  ///
  /// If the domain has more than two values, nicing the domain only affects the
  /// first and last value. Nicing a scale only modifies the current domain; it
  /// does not automatically nice domains that are subsequently set. You must
  /// re-nice the scale after setting the new domain, if desired.
  void nice([num count = 0]) {
    domain = nicee(domain, (
      floor: (num x) => _pows(_logs(x).floorToDouble()),
      ceil: (num x) => _pows(_logs(x).ceilToDouble())
    ));
  }
}

extension InitLoggish<Y> on Loggish<Y> {
  void initLoggish() {
    transform(_transformLog, _transformExp);
    _rescale();
  }
}

/// Logarithmic (“log”) scales are like
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html)
/// except that a logarithmic transform is applied to the input domain value
/// before the output range value is computed.
///
/// The mapping to the range value *y* can be expressed as a function of the
/// domain value *x: y = m log(x) + b*.
///
/// **CAUTION:** As log(0) = -∞, a log scale domain must be **strictly-positive
/// or strictly-negative**; the domain must not include or cross zero. A log
/// scale with a positive domain has a well-defined behavior for positive
/// values, and a log scale with a negative domain has a well-defined behavior
/// for negative values. (For a negative domain, input and output values are
/// implicitly multiplied by -1.) The behavior of the scale is undefined if you
/// pass a negative value to a log scale with a positive domain or vice versa.
///
/// {@category Log scales}
final class ScaleLog<Y> extends ScaleContinuousBase<num, Y> with Loggish<Y> {
  /// Constructs a new log scale with the specified [domain], [range] and
  /// [interpolate], the base 10, and [clamp]ing disabled.
  ///
  /// ```dart
  /// final x = ScaleLog(
  ///   domain: [1, 10],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[1, 10\].
  ScaleLog(
      {super.domain = const [1, 10],
      required super.range,
      required super.interpolate}) {
    initLoggish();
    numberize(identity, identity);
  }

  @override
  ScaleLog<Y> copy() => assign(
      ScaleLog<Y>(domain: domain, range: range, interpolate: this.interpolate),
      this)
    ..base = base;

  static ScaleLog<num> number(
      {List<num> domain = const [1, 10],
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScaleLog(domain: domain, range: range, interpolate: interpolate);
  }

  static ScaleLog<Object?> dynamic(
      {List<num> domain = const [1, 10],
      List<Object?> range = const <num>[0, 1],
      Interpolate<Object?> interpolate = interpolate}) {
    return ScaleLog(domain: domain, range: range, interpolate: interpolate);
  }
}
