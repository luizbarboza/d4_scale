import 'package:d4_array/d4_array.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleQuantize() has the expected defaults", () {
    final s = ScaleQuantize(range: [0, 1]);
    expect(s.domain, [0, 1]);
    expect(s.thresholds, [0.5]);
    expect(s(0.25), 0);
    expect(s(0.75), 1);
  });

  test("quantize(value) maps a number to a discrete value in the range", () {
    final s = ScaleQuantize(range: [0, 1, 2]);
    expect(s.thresholds, [1 / 3, 2 / 3]);
    expect(s(0.0), 0);
    expect(s(0.2), 0);
    expect(s(0.4), 1);
    expect(s(0.6), 1);
    expect(s(0.8), 2);
    expect(s(1.0), 2);
  });

  test("quantize(value) clamps input values to the domain", () {
    const a = {};
    const b = {};
    const c = {};
    final s = ScaleQuantize(range: [a, b, c]);
    expect(s(-0.5), a);
    expect(s(1.5), c);
  });

  test(
      "quantize.unknown(value) sets the return value for undefined, null, and NaN input",
      () {
    final s = ScaleQuantize(range: [0, 1, 2])..unknown = -1;
    expect(s(null), -1);
    expect(s(double.nan), -1);
  });

  test(
      "quantize.domain() only considers the first and second element of the domain",
      () {
    final s = ScaleQuantize(domain: [-1, 100, 200], range: [0, 1]);
    expect(s.domain, [-1, 100]);
  });

  test("quantize.range() cardinality determines the degree of quantization",
      () {
    final s = ScaleQuantize(range: <num>[0, 1]);
    expect((s..range = range(stop: 1.001, step: 0.001))(1 / 3),
        closeTo(0.333, 1e-6));
    expect((s..range = range(stop: 1.010, step: 0.010))(1 / 3),
        closeTo(0.330, 1e-6));
    expect((s..range = range(stop: 1.100, step: 0.100))(1 / 3),
        closeTo(0.300, 1e-6));
    expect((s..range = range(stop: 1.200, step: 0.200))(1 / 3),
        closeTo(0.400, 1e-6));
    expect((s..range = range(stop: 1.250, step: 0.250))(1 / 3),
        closeTo(0.250, 1e-6));
    expect((s..range = range(stop: 1.500, step: 0.500))(1 / 3),
        closeTo(0.500, 1e-6));
    expect((s..range = range(stop: 1))(1 / 3), closeTo(0, 1e-6));
  });

  test("quantize.range() values are arbitrary", () {
    const a = {};
    const b = {};
    const c = {};
    final s = ScaleQuantize(range: [a, b, c]);
    expect(s(0.0), a);
    expect(s(0.2), a);
    expect(s(0.4), b);
    expect(s(0.6), b);
    expect(s(0.8), c);
    expect(s(1.0), c);
  });

  test("quantize.invertExtent() maps a value in the range to a domain extent",
      () {
    final s = ScaleQuantize(range: [0, 1, 2, 3]);
    expect(s.invertExtent(0), (0.00, 0.25));
    expect(s.invertExtent(1), (0.25, 0.50));
    expect(s.invertExtent(2), (0.50, 0.75));
    expect(s.invertExtent(3), (0.75, 1.00));
  });

  test("quantize.invertExtent() allows arbitrary range values", () {
    const a = {"a": null};
    const b = {"b": null};
    final s = ScaleQuantize(range: [a, b]);
    expect(s.invertExtent(a), (0.0, 0.5));
    expect(s.invertExtent(b), (0.5, 1.0));
  });

  test(
      "quantize.invertExtent() returns [NaN, NaN] when the given value is not in the range",
      () {
    final s = ScaleQuantize<Object?>(range: [0, 1]);
    expect(toList(s.invertExtent(-1)), [isNaN, isNaN]);
    expect(toList(s.invertExtent(0.5)), [isNaN, isNaN]);
    expect(toList(s.invertExtent(2)), [isNaN, isNaN]);
    expect(toList(s.invertExtent("a")), [isNaN, isNaN]);
  });

  test(
      "quantize.invertExtent() returns the first match if duplicate values exist in the range",
      () {
    final s = ScaleQuantize(range: [0, 1, 2, 0]);
    expect(s.invertExtent(0), (0.00, 0.25));
    expect(s.invertExtent(1), (0.25, 0.50));
  });

  test("quantize.invertExtent(y) is exactly consistent with quantize(x)", () {
    final s = ScaleQuantize(domain: [4.2, 6.2], range: range(stop: 10));
    for (var y in s.range) {
      final e = s.invertExtent(y);
      expect(s(e.$1), y);
      expect(s(e.$2), y < 9 ? y + 1 : y);
    }
  });
}

List<num> toList((num, num) record) {
  return [record.$1, record.$2];
}
