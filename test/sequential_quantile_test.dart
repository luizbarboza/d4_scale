import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("sequentialQuantile() clamps", () {
    final s = ScaleSequentialQuantile.dynamic()..domain = [0, 1, 2, 3, 10];
    expect(s(-1), 0);
    expect(s(0), 0);
    expect(s(1), 0.25);
    expect(s(10), 1);
    expect(s(20), 1);
  });

  test("sequentialQuantile().domain() sorts the domain", () {
    final s = ScaleSequentialQuantile.dynamic()..domain = [0, 2, 9, 0.1, 10];
    expect(s.domain, [0, 0.1, 2, 9, 10]);
  });

  test("sequentialQuantile().range() returns the computed range", () {
    final s = ScaleSequentialQuantile.dynamic()..domain = [0, 2, 9, 0.1, 10];
    expect(s.range, [0 / 4, 1 / 4, 2 / 4, 3 / 4, 4 / 4]);
  });

  test("sequentialQuantile().quantiles(n) computes n + 1 quantiles", () {
    final s = ScaleSequentialQuantile.dynamic()
      ..domain = List.generate(2000, (i) => 2 * i / 1999);
    expect(s.quantiles(4), [0, 0.5, 1, 1.5, 2]);
  });
}
