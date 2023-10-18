import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleDiverging.dynamic() has the expected defaults", () {
    final s = ScaleDiverging.dynamic();
    expect(s.domain, [0, 0.5, 1]);
    expect(s.interpolator(0.42), 0.42);
    expect(s.clamp, false);
    expect(s(-0.5), -0.5);
    expect(s(0.0), 0.0);
    expect(s(0.5), 0.5);
    expect(s(1.0), 1.0);
    expect(s(1.5), 1.5);
  });

  test("diverging.clamp(true) enables clamping", () {
    final s = ScaleDiverging.dynamic()..clamp = true;
    expect(s.clamp, true);
    expect(s(-0.5), 0.0);
    expect(s(0.0), 0.0);
    expect(s(0.5), 0.5);
    expect(s(1.0), 1.0);
    expect(s(1.5), 1.0);
  });

  test("diverging.domain() handles a degenerate domain", () {
    final s = ScaleDiverging.dynamic()..domain = [2, 2, 3];
    expect(s.domain, [2, 2, 3]);
    expect(s(-1.2), 0.5);
    expect(s(0.6), 0.5);
    expect(s(2.4), 0.7);
    expect((s..domain = [1, 2, 2]).domain, [1, 2, 2]);
    expect(s(-1.0), -1);
    expect(s(0.5), -0.25);
    expect(s(2.4), 0.5);
    expect((s..domain = [2, 2, 2]).domain, [2, 2, 2]);
    expect(s(-1.0), 0.5);
    expect(s(0.5), 0.5);
    expect(s(2.4), 0.5);
  });

  test("diverging.domain() handles a descending domain", () {
    final s = ScaleDiverging.dynamic()..domain = [4, 2, 1];
    expect(s.domain, [4, 2, 1]);
    expect(s(1.2), 0.9);
    expect(s(2.0), 0.5);
    expect(s(3.0), 0.25);
  });

  test("divergingLog.domain() handles a descending domain", () {
    final s = ScaleDivergingLog.dynamic()..domain = [3, 2, 1];
    expect(s.domain, [3, 2, 1]);
    expect(s(1.2), 1 - 0.1315172029168969);
    expect(s(2.0), 1 - 0.5000000000000000);
    expect(s(2.8), closeTo(1 - 0.9149213210862197, 1e-12));
  });

  test("divergingLog.domain() handles a descending negative domain", () {
    final s = ScaleDivergingLog.dynamic()..domain = [-1, -2, -3];
    expect(s.domain, [-1, -2, -3]);
    expect(s(-1.2), 0.1315172029168969);
    expect(s(-2.0), 0.5000000000000000);
    expect(s(-2.8), closeTo(0.9149213210862197, 1e-12));
  });

  test("diverging.domain() handles a non-numeric domain", () {
    final s = ScaleDiverging.dynamic()..domain = [double.nan, 2, 3];
    expect(s.domain[0], isNaN);
    expect(s(-1.2), isNaN);
    expect(s(0.6), isNaN);
    expect(s(2.4), 0.7);
    expect((s..domain = [1, double.nan, 2]).domain[1], isNaN);
    expect(s(-1.0), isNaN);
    expect(s(0.5), isNaN);
    expect(s(2.4), isNaN);
    expect((s..domain = [0, 1, double.nan]).domain[2], isNaN);
    expect(s(-1.0), -0.5);
    expect(s(0.5), 0.25);
    expect(s(2.4), isNaN);
  });

  test(
      "diverging.domain() only considers the first three elements of the domain",
      () {
    final s = ScaleDiverging.dynamic()..domain = [-1, 100, 200, 3];
    expect(s.domain, [-1, 100, 200]);
  });

  test("diverging.copy() returns an isolated copy of the scale", () {
    final s1 = ScaleDiverging.dynamic()
      ..domain = [1, 2, 3]
      ..clamp = true;
    final s2 = s1.copy();
    expect(s2.domain, [1, 2, 3]);
    expect(s2.clamp, true);
    s1.domain = [-1, 1, 2];
    expect(s2.domain, [1, 2, 3]);
    s1.clamp = false;
    expect(s2.clamp, true);
    s2.domain = [3, 4, 5];
    expect(s1.domain, [-1, 1, 2]);
    s2.clamp = true;
    expect(s1.clamp, false);
  });

  test("diverging.range() returns the computed range", () {
    final s = ScaleDiverging(interpolator: (t) {
      return t * 2 + 1;
    });
    expect(s.range, [1, 2, 3]);
  });

  test("diverging.interpolator(interpolator) sets the interpolator", () {
    i0(t) {
      return t;
    }

    i1(t) {
      return t * 2;
    }

    final s = ScaleDiverging(interpolator: i0);
    expect(s.interpolator, i0);
    expect(s..interpolator = i1, s);
    expect(s.interpolator, i1);
    expect(s(-0.5), -1.0);
    expect(s(0.0), 0.0);
    expect(s(0.5), 1.0);
  });

  test("diverging.range(range) sets the interpolator", () {
    final s = ScaleDiverging.dynamic()..range = [1, 3, 10];
    expect(s.interpolator(0.5), 3);
    expect(s.range, [1, 3, 10]);
  });

  test("diverging.range(range) ignores additional values", () {
    final s = ScaleDiverging.dynamic()..range = [1, 3, 10, 20];
    expect(s.interpolator(0.5), 3);
    expect(s.range, [1, 3, 10]);
  });

  /*test("scaleDiverging(range) sets the interpolator", () {
    final s = ScaleDiverging.dynamic(domain: [1, 3, 10]);
    expect(s.interpolator(0.5), 3);
    expect(s.range, [1, 3, 10]);
  });*/
}
