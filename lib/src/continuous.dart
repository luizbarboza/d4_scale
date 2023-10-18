import 'dart:math' as math;

import 'package:d4_array/d4_array.dart';
import 'package:d4_interpolate/d4_interpolate.dart';

import 'constant.dart';
import 'interpolator.dart';
import 'scale.dart';

const unit = [0, 1];

T identity<T>(T x) {
  return x;
}

num Function(num) _normalize(num a, num b) {
  return ((b -= a) != 0 && !b.isNaN
      ? (num x) {
          return (x - a) / b;
        }
      : constant(b.isNaN ? double.nan : 0.5)) as num Function(num);
}

num Function(num) _clamper(num a, num b) {
  if (a > b) {
    (a, b) = (b, a);
  }
  return (x) {
    return math.max(a, math.min(b, x));
  };
}

// normalize(a, b)(x) takes a domain value x in [a,b] and returns the corresponding parameter t in [0,1].
// interpolate(a, b)(t) takes a parameter t in [0,1] and returns the corresponding range value x in [a,b].
T Function(num) _bimap<T>(List<num> domain, List<T> range,
    T Function(num) Function(T, T) interpolate) {
  var d0 = domain[0], d1 = domain[1], r0 = range[0], r1 = range[1];

  num Function(num) d;
  T Function(num) r;

  if (d1 < d0) {
    d = _normalize(d1, d0);
    r = interpolate(r1, r0);
  } else {
    d = _normalize(d0, d1);
    r = interpolate(r0, r1);
  }
  return (x) {
    return r(d(x));
  };
}

T Function(num) _polymap<T>(List<num> domain, List<T> range,
    T Function(num) Function(T, T) interpolate) {
  var j = math.min(domain.length, range.length) - 1;

  // Reverse descending domains.
  if (domain[j] < domain[0]) {
    domain = reverse(domain);
    range = reverse(range);
  }

  var di = domain[0],
      ri = range[0],
      d = List.generate(
          j < 0 ? 0 : j, (i) => _normalize(di, (di = domain[++i]))),
      r = List.generate(
          j < 0 ? 0 : j, (i) => interpolate(ri, (ri = range[++i])));

  return (x) {
    var i = bisectRight(domain, x, lo: 1, hi: j) - 1;
    return r[i](d[i](x));
  };
}

S assign<X, Y, S extends ScaleContinuousBase<X, Y>>(
    S target, ScaleContinuousBase<X, Y> source) {
  return target
    ..domain = source.domain
    ..clamp = source.clamp
    ..unknown = source.unknown;
}

abstract base class ScaleContinuousBase<X, Y> implements Scale<X, Y> {
  List<X> _domain;
  List<Y> _range;
  Interpolate<Y> _interpolate;
  late num Function(num) _transform, _untransform;
  late num Function(X) _numberize;
  late X Function(num) _unnumberize;
  Y? _unknown;
  bool _clamp = false;
  num Function(num) _clampf = identity;
  late Piecewise<Y> _piecewise;
  Y Function(num)? _output;
  num Function(num)? _input;

  ScaleContinuousBase(
      {required List<X> domain,
      required List<Y> range,
      required Interpolate<Y> interpolate})
      : _domain = domain,
        _range = range,
        _interpolate = interpolate;

  void _rescale() {
    var n = math.min(_domain.length, _range.length);
    if (_clamp) {
      _clampf = _clamper(_numberize(_domain[0]), _numberize(_domain[n - 1]));
    }
    _piecewise = n > 2 ? _polymap : _bimap;
    _output = _input = null;
  }

  /// Given a value from the [domain], returns the corresponding value from the
  /// [range].
  ///
  /// If the given value is outside the domain, and [clamp]ing is not enabled,
  /// the mapping will be extrapolated such that the returned value is outside
  /// the range. For example, to apply a position encoding:
  ///
  /// ```dart
  /// var x = ScaleLinear(
  ///   domain: [10, 130],
  ///   range: [0, 960],
  ///   interpolate: interpolate,
  /// );
  ///
  /// x(20); // 80
  /// x(50); // 320
  /// ```
  ///
  /// Or to apply a color encoding:
  ///
  /// ```dart
  /// var x = ScaleLinear(
  ///   domain: [10, 100],
  ///   range: ["brown", "steelblue"],
  ///   interpolate: interpolate,
  /// );
  ///
  /// x(20); // "#9a3439"
  /// x(50); // "#7b5167"
  /// ```
  @override
  Y? call(X? x) {
    final num nx;
    return x == null || (nx = _numberize(x)).isNaN
        ? _unknown
        : (_output ??
            (_output = _piecewise(
                _domain.map((x) => _transform(_numberize(x))).toList(),
                _range,
                _interpolate)))(_transform(_clampf(nx)));
  }

  /// The scale's domain that specifies the input values.
  ///
  /// The list must contain two or more elements. Although continuous scales
  /// typically have two values each in their domain and range, specifying more
  /// than two values produces a piecewise scale. For example, to create a
  /// [diverging color scale](https://pub.dev/documentation/d4_scale/latest/topics/Diverging%20scales-topic.html)
  /// that interpolates between white and red for negative values, and white and
  /// green for positive values, say:
  ///
  /// ```dart
  /// var color = ScaleLinear(
  ///   domain: [-1, 0, 1],
  ///   range: ["red", "white", "green"],
  ///   interpolate: interpolateRgb,
  /// );
  ///
  /// color(-0.5); // "rgb(255, 128, 128)"
  /// color(0.5); // "rgb(128, 192, 128)"
  /// ```
  ///
  /// Internally, a piecewise scale performs a binary search (see [bisectRight])
  /// for the range interpolator corresponding to the given domain value. Thus,
  /// the domain must be in ascending or descending order. If the domain and
  /// range have different lengths *N* and *M*, only the first *min(N,M)*
  /// elements in each are observed.
  @override
  List<X> get domain => _domain.sublist(0);
  @override
  set domain(List<X> domain) {
    _domain = List<X>.of(domain);
    _rescale();
  }

  /// The scale's range that specifies the output values.
  ///
  /// The list must contain two or more elements. Any value that is supported by
  /// the underlying interpolator (see [interpolate] for examples) will work,
  /// though note that numeric ranges are required for
  /// [ScaleContinuousNumberExtension.invert].
  @override
  List<Y> get range => _range.sublist(0);
  @override
  set range(List<Y> range) {
    _range = List<Y>.of(range);
    _rescale();
  }

  /// Whether or not the scale currently clamps values to within the [range].
  ///
  /// If clamping is disabled and the scale is passed a value outside the
  /// [domain], the scale may return a value outside the [range] through
  /// extrapolation. If clamping is enabled, the return value of the scale is
  /// always within the scale’s range. Clamping similarly applies to
  /// [ScaleContinuousNumberExtension.invert]. For example:
  ///
  /// ```dart
  /// var x = ScaleLinear(
  ///   domain: [10, 130],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// );
  ///
  /// x(-10); // -160, outside range
  /// x.invert(-160); // -10, outside domain
  ///
  /// x.clamp = true;
  /// x(-10); // 0, clamped to range
  /// x.invert(-160); // 10, clamped to domain
  /// ```
  bool get clamp => _clamp;
  set clamp(bool clamp) {
    _clamp = clamp;
    _clampf = identity;
    _rescale();
  }

  /// The scale’s [range] interpolator factory.
  ///
  /// This interpolator factory is used to create interpolators for each
  /// adjacent pair of values from the range; these interpolators then map a
  /// normalized domain parameter *t* in \[0, 1\] to the corresponding value in
  /// the range. See
  /// [d4_interpolate](https://pub.dev/documentation/d4_interpolate/latest/d4_interpolate/d4_interpolate-library.html) for
  /// more interpolators.
  ///
  /// For example, consider a diverging color scale with three colors in the
  /// range:
  ///
  /// ```dart
  /// var color = ScaleLinear(
  ///   domain: [-100, 0, 100],
  ///   range: ["red", "white", "green"],
  ///   interpolate: interpolate,
  /// );
  /// ```
  ///
  /// Two interpolators are created internally by the scale, equivalent to:
  ///
  /// ```dart
  /// var i0 = interpolate("red", "white"),
  ///     i1 = interpolate("white", "green");
  /// ```
  ///
  /// A common reason to specify a custom interpolator is to change the color
  /// space of interpolation. For example, to use HCL (see [interpolateHcl]):
  ///
  /// ```dart
  /// var color = ScaleLinear(
  ///   domain: [10, 100],
  ///   range: ["brown", "steelblue"],
  ///   interpolate: interpolateHcl,
  /// );
  /// ```
  ///
  /// Or for Cubehelix with a custom gamma (see [interpolateCubehelixGamma]).
  ///
  /// ```dart
  /// var color = ScaleLinear(
  ///   domain: [10, 100],
  ///   range: ["brown", "steelblue"],
  ///   interpolate: interpolateCubehelixGamma(3),
  /// );
  /// ```
  Interpolate<Y> get interpolate => _interpolate;
  set interpolate(Interpolate<Y> interpolate) {
    _interpolate = interpolate;
    _rescale();
  }

  /// The output value of the scale for null (or [double.nan]) input values.
  ///
  /// Defaults to null.
  Y? get unknown => _unknown;
  set unknown(Y? unknown) {
    _unknown = unknown;
    _rescale();
  }

  List<X> ticks([num count]);

  String Function(X) tickFormat([num count, String? specifier]);

  void nice([num count]);
}

abstract final class ScaleContinuous<X, Y> extends ScaleContinuousBase<X, Y> {
  ScaleContinuous(
      {required super.domain,
      required super.range,
      required super.interpolate});

  @override
  ScaleContinuous<X, Y> copy();
}

/// Adds [invert] and [rangeRound] methods to continuous scales with numeric
/// range.
extension ScaleContinuousNumberExtension<X> on ScaleContinuousBase<X, num> {
  /// Given a value from the [range], returns the corresponding value from the
  /// [domain].
  ///
  /// Inversion is useful for interaction, say to determine the data value
  /// corresponding to the position of the mouse. For example, to invert a
  /// position encoding:
  ///
  /// ```dart
  /// var x = ScaleLinear(
  ///   domain: [10, 130],
  ///   range: [0, 960],
  ///   interpolate: interpolate,
  /// );
  ///
  /// x(80); // 20
  /// x(320); // 50
  /// ```
  ///
  /// If the given value is outside the range, and [clamp]ing is not enabled,
  /// the mapping may be extrapolated such that the returned value is outside
  /// the domain. This method is only supported if the range is numeric.
  ///
  /// For a valid value *y* in the range, *continuous*(*continuous*.invert(*y*))
  /// approximately equals *y*; similarly, for a valid value *x* in the domain,
  /// *continuous*.invert(*continuous*(*x*)) approximately equals *x*. The scale
  /// and its inverse may not be exact due to the limitations of floating point
  /// precision.
  X invert(num y) {
    return _unnumberize(_clampf(_untransform((_input ??
        (_input = _piecewise(
            _range,
            _domain.map((x) => _transform(_numberize(x))).toList(),
            interpolateNumber)))(y))));
  }

  /// Sets the scale’s [range] to the specified list of values while also
  /// setting the scale’s [interpolate] to [interpolateRound].
  ///
  /// This is a convenience method equivalent to:
  ///
  /// ```dart
  /// continuous
  ///   ..range = range
  ///   ..interpolate = interpolateRound;
  /// ```
  ///
  /// The rounding interpolator is sometimes useful for avoiding antialiasing
  /// artifacts, though also consider the
  /// [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering)
  /// “crispEdges” styles. Note that this interpolator can only be used with
  /// numeric ranges.
  void rangeRound(List<num> range) {
    this
      ..range = range
      ..interpolate = interpolateRound;
    _rescale();
  }
}

extension ScaleContinuousTransform<X, Y> on ScaleContinuousBase<X, Y> {
  void transform(num Function(num) t, num Function(num) u) {
    _transform = t;
    _untransform = u;
    _rescale();
  }

  void numberize(num Function(X) n, X Function(num) u) {
    _numberize = n;
    _unnumberize = u;
    _rescale();
  }
}
