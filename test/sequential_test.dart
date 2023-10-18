import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleSequential.dynamic() has the expected defaults", () {
    final s = ScaleSequential.dynamic();
    expect(s.domain, [0, 1]);
    expect(s.interpolator(0.42), 0.42);
    expect(s.clamp, false);
    expect(s.unknown, null);
    expect(s(-0.5), -0.5);
    expect(s(0.0), 0.0);
    expect(s(0.5), 0.5);
    expect(s(1.0), 1.0);
    expect(s(1.5), 1.5);
  });

  test("sequential.clamp(true) enables clamping", () {
    final s = ScaleSequential.dynamic()..clamp = true;
    expect(s.clamp, true);
    expect(s(-0.5), 0.0);
    expect(s(0.0), 0.0);
    expect(s(0.5), 0.5);
    expect(s(1.0), 1.0);
    expect(s(1.5), 1.0);
  });

  test(
      "sequential.unknown(value) sets the return value for undefined and NaN input",
      () {
    final s = ScaleSequential.dynamic()..unknown = -1;
    expect(s.unknown, -1);
    expect(s(null), -1);
    expect(s(double.nan), -1);
    expect(s(0.4), 0.4);
  });

  test("sequential.domain() handles a degenerate domain", () {
    final s = ScaleSequential.dynamic()..domain = [2, 2];
    expect(s.domain, [2, 2]);
    expect(s(-1.2), 0.5);
    expect(s(0.6), 0.5);
    expect(s(2.4), 0.5);
  });

  test("sequential.domain() handles a non-numeric domain", () {
    final s = ScaleSequential.dynamic()..domain = [double.nan, 2];
    expect(s.domain[0], isNaN);
    expect(s.domain[1], 2);
    expect(s(-1.2), isNaN);
    expect(s(0.6), isNaN);
    expect(s(2.4), isNaN);
  });

  test(
      "sequential.domain() only considers the first and second element of the domain",
      () {
    final s = ScaleSequential.dynamic()..domain = [-1, 100, 200];
    expect(s.domain, [-1, 100]);
  });

  test("sequential.copy() returns an isolated copy of the scale", () {
    final s1 = ScaleSequential.dynamic()
      ..domain = [1, 3]
      ..clamp = true;
    final s2 = s1.copy();
    expect(s2.domain, [1, 3]);
    expect(s2.clamp, true);
    s1.domain = [-1, 2];
    expect(s2.domain, [1, 3]);
    s1.clamp = false;
    expect(s2.clamp, true);
    s2.domain = [3, 4];
    expect(s1.domain, [-1, 2]);
    s2.clamp = true;
    expect(s1.clamp, false);
  });

  test("sequential.interpolator(interpolator) sets the interpolator", () {
    i0(t) {
      return t;
    }

    i1(t) {
      return t * 2;
    }

    final s = ScaleSequential(interpolator: i0);
    expect(s.interpolator, i0);
    expect(s..interpolator = i1, s);
    expect(s.interpolator, i1);
    expect(s(-0.5), -1.0);
    expect(s(0.0), 0.0);
    expect(s(0.5), 1.0);
  });

  test("sequential.range() returns the computed range", () {
    final s = ScaleSequential(interpolator: (t) {
      return t * 2 + 1;
    });
    expect(s.range, [1, 3]);
  });

  test("sequential.range(range) sets the interpolator", () {
    final s = ScaleSequential.dynamic()..range = [1, 3];
    expect(s.interpolator(0.5), 2);
    expect(s.range, [1, 3]);
  });

  test("sequential.range(range) ignores additional values", () {
    final s = ScaleSequential.dynamic()..range = [1, 3, 10];
    expect(s.interpolator(0.5), 2);
    expect(s.range, [1, 3]);
  });

  /*test("scaleSequential(range) sets the interpolator", () {
    final s = ScaleSequential([1, 3]);
    expect(s.interpolator(0.5), 2);
    expect(s.range, [1, 3]);
  });*/
}
