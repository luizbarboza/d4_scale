import 'scale.dart';

/// Unlike
/// [continuous scales](https://pub.dev/documentation/d4_scale/latest/topics/Linear%20scales-topic.html),
/// ordinal scales have a discrete domain and range.
///
/// For example, an ordinal scale might map a set of named categories to a set
/// of colors, or determine the horizontal positions of columns in a column
/// chart.
///
/// {@category Ordinal scales}
class ScaleOrdinal<X, Y> implements Scale<X, Y> {
  var _index = <X, int>{};
  List<X> _domain = [];
  List<Y> _range = [];

  /// The output value of the scale for unknown input values.
  ///
  /// ```dart
  /// final color = ScaleOrdinal(
  ///   domain: ["a", "b", "c"],
  ///   range: schemeTableau10,
  /// )..unknown = null;
  /// color("a"); // "#4e79a7"
  /// color("b"); // "#f28e2c"
  /// color("c"); // "#e15759"
  /// color("d"); // null
  /// ```
  ///
  /// Defaults to null.
  Y? unknown;

  /// Whether or not the scale currently infers domain implicitly from usage.
  ///
  /// See [domain].
  bool implicit = true;

  /// Constructs a new ordinal scale with the specified [domain] and [range].
  ///
  /// ```dart
  /// final color = ScaleOrdinal(
  ///   domain: ["a", "b", "c"],
  ///   range: ["red", "green", "blue"],
  /// );
  /// ```
  ///
  /// If [domain] is not specified, it defaults to the empty array. If [range]
  /// is not specified, it defaults to the empty array; an ordinal scale always
  /// returns undefined until a non-empty range is defined.
  ScaleOrdinal({List<X>? domain, List<Y>? range}) {
    if (range != null) this.range = range;
    if (domain != null) this.domain = domain;
  }

  /// Given a value in the input [domain], returns the corresponding value in
  /// the output [range].
  ///
  /// ```dart
  /// color("a") // "red"
  /// ```
  ///
  /// If the given value is not in the scale’s [domain], returns the [unknown]
  /// value; or, if [implicit] is true (the default), then the value is
  /// implicitly added to the domain and the next-available value in the range
  /// is assigned to value, such that this and subsequent invocations of the
  /// scale given the same input value return the same output value.
  @override
  call(d) {
    var i = _index[d];
    if (i == null) {
      if (!implicit) return unknown;
      _index[d!] = i = (_domain..add(d)).length - 1;
    }
    return _range.isEmpty ? null : _range[i.remainder(_range.length)];
  }

  /// The scale's domain that specifies the input values.
  ///
  /// ```dart
  /// final color = ScaleOrdinal(
  ///   range: ["red", "green", "blue"],
  /// )..domain = ["a", "b", "c"];
  /// color("a"); // "red"
  /// color("b"); // "green"
  /// color("c"); // "blue"
  /// ```
  ///
  /// The first element in [domain] will be mapped to the first element in the
  /// range, the second domain value to the second range value, and so on.
  ///
  /// Setting the domain on an ordinal scale is optional if the implicit is true
  /// (the default). In this case, the domain will be inferred implicitly from
  /// usage by assigning each unique value passed to the scale a new value from
  /// the range.
  ///
  /// ```dart
  /// final color = ScaleOrdinal(range: ["red", "green", "blue"]);
  /// color("b"); // "red"
  /// color("a"); // "green"
  /// color("c"); // "blue"
  /// color.domain; // inferred ["b", "a", "c"]
  /// ```
  ///
  /// **CAUTION**: An explicit domain is recommended for deterministic behavior;
  /// inferring the domain from usage is dependent on ordering.
  @override
  get domain => _domain.sublist(0);
  @override
  set domain(List<X> domain) {
    _domain = [];
    _index = <X, int>{};
    for (final value in domain) {
      if (_index.containsKey(value)) continue;
      _index[value] = (_domain..add(value)).length - 1;
    }
  }

  /// The scale's range that specifies the output values.
  ///
  /// ```dart
  /// final color = ScaleOrdinal()..range = ["red", "green", "blue"];
  /// ```
  ///
  /// The first element in the domain will be mapped to the first element in
  /// [range], the second domain value to the second range value, and so on. If
  /// there are fewer elements in the range than in the domain, the scale will
  /// reuse values from the start of the range.
  @override
  get range => _range.sublist(0);
  @override
  set range(range) {
    _range = List<Y>.of(range);
  }

  /// Returns an exact copy of this ordinal scale.
  ///
  /// ```dart
  /// final c1 = ScaleOrdinal(
  ///   domain: ["a", "b", "c"],
  ///   range: schemeTableau10,
  /// );
  /// final c2 = c1.copy();
  /// ```
  ///
  /// Changes to this scale will not affect the returned scale, and vice versa.
  @override
  ScaleOrdinal<X, Y> copy() {
    return ScaleOrdinal()
      ..domain = domain
      ..range = _range
      ..unknown = unknown;
  }
}
