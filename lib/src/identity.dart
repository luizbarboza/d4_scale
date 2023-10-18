import 'continuous.dart';
import 'linear.dart';

/// Identity scales are a special case of
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html)
/// where the domain and range are identical.
///
/// The scale and its invert method are thus the identity function. These scales
/// are occasionally useful when working with pixel coordinates, say in
/// conjunction with an axis. Identity scales do not support
/// [ScaleContinuousNumberExtension.rangeRound], [ScaleLinear.clamp] or
/// [ScaleLinear.interpolate].
///
/// {@category Linear scales}
final class ScaleIdentity with Linearish<num> {
  late List<num> _range;
  num? unknown;

  /// Constructs a new identity scale with the specified [range] (and by
  /// extension, [domain]).
  ///
  /// ```dart
  /// final x = ScaleIdentity(range: [0, 960]);
  /// ```
  ///
  /// If [range] is not specified, it defaults to \[0, 1\].
  ScaleIdentity({List<num> range = const [0, 1]}) {
    this.range = range;
  }

  @override
  call(x) {
    return x == null || x.isNaN ? unknown : x;
  }

  num? invert(num? x) => call(x);

  @override
  get domain => range;
  @override
  set domain(domain) => range = domain;

  @override
  get range => _range.sublist(0);
  @override
  set range(range) => _range = List.of(range);

  @override
  copy() => ScaleIdentity(range: _range)..unknown = unknown;
}
