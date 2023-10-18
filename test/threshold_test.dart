import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("threshold(x) maps a number to a discrete value in the range", () {
    final x = ScaleThreshold(domain: [1 / 3, 2 / 3], range: ["a", "b", "c"]);
    expect(x(0), "a");
    expect(x(0.2), "a");
    expect(x(0.4), "b");
    expect(x(0.6), "b");
    expect(x(0.8), "c");
    expect(x(1), "c");
  });

  test(
      "threshold(x) returns undefined if the specified value x is not orderable",
      () {
    final x = ScaleThreshold(domain: [1 / 3, 2 / 3], range: ["a", "b", "c"]);
    expect(x(null), null);
    expect(x(double.nan), null);
  });

  test("threshold.range(…) supports arbitrary values", () {
    final a = {},
        b = {},
        c = {},
        x = ScaleThreshold(domain: [1 / 3, 2 / 3], range: [a, b, c]);
    expect(x(0), a);
    expect(x(0.2), a);
    expect(x(0.4), b);
    expect(x(0.6), b);
    expect(x(0.8), c);
    expect(x(1), c);
  });

  test(
      "threshold.invertExtent(y) returns the domain extent for the specified range value",
      () {
    final a = {"a": null},
        b = {"b": null},
        c = {"c": null},
        x = ScaleThreshold(domain: [1 / 3, 2 / 3], range: [a, b, c]);
    expect(x.invertExtent(a), (null, 1 / 3));
    expect(x.invertExtent(b), (1 / 3, 2 / 3));
    expect(x.invertExtent(c), (2 / 3, null));
    expect(x.invertExtent({}), (null, null));
  });
}
