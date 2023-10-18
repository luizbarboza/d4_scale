import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleQuantile() has the expected default", () {
    final s = ScaleQuantile(domain: [], range: []);
    expect(s.unknown, null);
  });

  test("quantile(x) uses the R-7 algorithm to compute quantiles", () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 3]);
    expect([3, 6, 6.9, 7, 7.1].map(s), [0, 0, 0, 0, 0]);
    expect([8, 8.9].map(s), [1, 1]);
    expect([9, 9.1, 10, 13].map(s), [2, 2, 2, 2]);
    expect([14.9, 15, 15.1, 16, 20].map(s), [3, 3, 3, 3, 3]);
    s
      ..domain = [3, 6, 7, 8, 8, 9, 10, 13, 15, 16, 20]
      ..range = [0, 1, 2, 3];
    expect([3, 6, 6.9, 7, 7.1].map(s), [0, 0, 0, 0, 0]);
    expect([8, 8.9].map(s), [1, 1]);
    expect([9, 9.1, 10, 13].map(s), [2, 2, 2, 2]);
    expect([14.9, 15, 15.1, 16, 20].map(s), [3, 3, 3, 3, 3]);
  });

  test("quantile(x) returns undefined if the input value is NaN", () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 3]);
    expect(s(double.nan), null);
  });

  test("quantile.domain() values are sorted in ascending order", () {
    final s =
        ScaleQuantile(domain: [6, 3, 7, 8, 8, 13, 20, 15, 16, 10], range: []);
    expect(s.domain, [3, 6, 7, 8, 8, 10, 13, 15, 16, 20]);
  });

  test("quantile.domain() values are allowed to be zero", () {
    final s = ScaleQuantile(domain: [1, 2, 0, 0, null], range: []);
    expect(s.domain, [0, 0, 1, 2]);
  });

  test("quantile.domain() non-numeric values are ignored", () {
    final s = ScaleQuantile(domain: [
      6,
      3,
      double.nan,
      null,
      7,
      8,
      8,
      13,
      null,
      20,
      15,
      16,
      10,
      double.nan
    ], range: []);
    expect(s.domain, [3, 6, 7, 8, 8, 10, 13, 15, 16, 20]);
  });

  test("quantile.quantiles() returns the inner thresholds", () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 3]);
    expect(s.quantiles, [7.25, 9, 14.5]);
    s
      ..domain = [3, 6, 7, 8, 8, 9, 10, 13, 15, 16, 20]
      ..range = [0, 1, 2, 3];
    expect(s.quantiles, [7.5, 9, 14]);
  });

  test("quantile.range() cardinality determines the number of quantiles", () {
    final s =
        ScaleQuantile(domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: []);
    expect((s..range = [0, 1, 2, 3]).quantiles, [7.25, 9, 14.5]);
    expect((s..range = [0, 1]).quantiles, [9]);
    expect((s..range = [null, null, null, null, null]).quantiles,
        [6.8, 8, 11.2, 15.2]);
    expect((s..range = [null, null, null, null, null, null]).quantiles,
        [6.5, 8, 9, 13, 15.5]);
  });

  test("quantile.range() values are arbitrary", () {
    const a = {};
    const b = {};
    const c = {};
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [a, b, c, a]);
    expect([3, 6, 6.9, 7, 7.1].map(s), [a, a, a, a, a]);
    expect([8, 8.9].map(s), [b, b]);
    expect([9, 9.1, 10, 13].map(s), [c, c, c, c]);
    expect([14.9, 15, 15.1, 16, 20].map(s), [a, a, a, a, a]);
  });

  test("quantile.invertExtent() maps a value in the range to a domain extent",
      () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 3]);
    expect(s.invertExtent(0), (3, 7.25));
    expect(s.invertExtent(1), (7.25, 9));
    expect(s.invertExtent(2), (9, 14.5));
    expect(s.invertExtent(3), (14.5, 20));
  });

  test("quantile.invertExtent() allows arbitrary range values", () {
    const a = {"a": null};
    const b = {"b": null};
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [a, b]);
    expect(s.invertExtent(a), (3, 9));
    expect(s.invertExtent(b), (9, 20));
  });

  test(
      "quantile.invertExtent() returns [NaN, NaN] when the given value is not in the range",
      () {
    final s =
        ScaleQuantile(domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: []);
    expect(toList(s.invertExtent(-1)), [isNaN, isNaN]);
    expect(toList(s.invertExtent(0.5)), [isNaN, isNaN]);
    expect(toList(s.invertExtent(2)), [isNaN, isNaN]);
    expect(toList(s.invertExtent('a')), [isNaN, isNaN]);
  });

  test(
      "quantile.invertExtent() returns the first match if duplicate values exist in the range",
      () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 0]);
    expect(s.invertExtent(0), (3, 7.25));
    expect(s.invertExtent(1), (7.25, 9));
    expect(s.invertExtent(2), (9, 14.5));
  });

  test(
      "quantile.unknown(value) sets the return value for undefined, null, and NaN input",
      () {
    final s = ScaleQuantile(
        domain: [3, 6, 7, 8, 8, 10, 13, 15, 16, 20], range: [0, 1, 2, 3])
      ..unknown = -1;
    expect(s(null), -1);
    expect(s(double.nan), -1);
    expect(s(2), 0);
    expect(s(3), 0);
    expect(s(21), 3);
  });
}

List<num> toList((num, num) record) {
  return [record.$1, record.$2];
}
