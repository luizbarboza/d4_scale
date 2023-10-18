import 'dart:math';

import 'continuous.dart';
import 'linear.dart';

num _square(num x) {
  return x.sign * x * x;
}

num _unsquare(num x) {
  return x.sign * sqrt(x.abs());
}

/// Radial scales are a variant of
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html)
/// where the range is internally squared so that an input value corresponds
/// linearly to the squared output value.
///
/// These scales are useful when you want the input value to correspond to the
/// area of a graphical mark and the mark is specified by radius, as in a radial
/// bar chart. Radial scales do not support [ScaleLinear.interpolate].
///
/// {@category Linear scales}
final class ScaleRadial with Linearish<num> {
  final _squared = ScaleLinear.number();
  var _range = <num>[0, 1], round = false;
  num? unknown;

  /// Constructs a new radial scale with the specified [domain] and [range].
  ///
  /// If domain or range is not specified, each defaults to \[0, 1\].
  ScaleRadial(
      {List<num> domain = const [0, 1], List<num> range = const [0, 1]}) {
    this.domain = domain;
    this.range = range;
  }

  @override
  call(x) {
    var y = _unsquare(_squared(x) ?? double.nan);
    return y.isNaN
        ? unknown
        : round
            ? y.round()
            : y;
  }

  invert(y) {
    return _squared.invert(_square(y));
  }

  @override
  set domain(domain) {
    _squared.domain = domain;
  }

  @override
  get domain {
    return _squared.domain;
  }

  @override
  set range(range) {
    _squared.range = (_range = range).map(_square).toList();
  }

  @override
  get range {
    return _range.sublist(0);
  }

  void rangeRound(List<num> range) {
    this
      ..range = range
      ..round = true;
  }

  set clamp(bool clamp) {
    _squared.clamp = clamp;
  }

  bool get clamp {
    return _squared.clamp;
  }

  @override
  copy() {
    return ScaleRadial(domain: domain, range: range)
      ..round = round
      ..clamp = clamp
      ..unknown = unknown;
  }
}
