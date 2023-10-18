import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleRadial() has the expected defaults", () {
    final s = ScaleRadial();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
    expect(s.clamp, false);
    expect(s.round, false);
  });

  test("ScaleRadial(range) sets the range", () {
    final s = ScaleRadial(range: [100, 200]);
    expect(s.domain, [0, 1]);
    expect(s.range, [100, 200]);
    expect(s(0.5), 158.11388300841898);
  });

  test("ScaleRadial(domain, range) sets the range", () {
    final s = ScaleRadial(domain: [1, 2], range: [10, 20]);
    expect(s.domain, [1, 2]);
    expect(s.range, [10, 20]);
    expect(s(1.5), 15.811388300841896);
  });

  test("radial(x) maps a domain value x to a range value y", () {
    expect(ScaleRadial(range: [1, 2])(0.5), 1.5811388300841898);
  });

  test(
      "radial(x) ignores extra range values if the domain is smaller than the range",
      () {
    expect(
        (ScaleRadial()
          ..domain = [-10, 0]
          ..range = [2, 3, 4]
          ..clamp = true)(-5),
        2.5495097567963922);
    expect(
        (ScaleRadial()
          ..domain = [-10, 0]
          ..range = [2, 3, 4]
          ..clamp = true)(50),
        3);
  });

  test(
      "radial(x) ignores extra domain values if the range is smaller than the domain",
      () {
    expect(
        (ScaleRadial()
          ..domain = [-10, 0, 100]
          ..range = [2, 3]
          ..clamp = true)(-5),
        2.5495097567963922);
    expect(
        (ScaleRadial()
          ..domain = [-10, 0, 100]
          ..range = [2, 3]
          ..clamp = true)(50),
        3);
  });

  test("radial(x) maps an empty domain to the middle of the range", () {
    expect(
        (ScaleRadial()
          ..domain = [0, 0]
          ..range = [1, 2])(0),
        1.5811388300841898);
    expect(
        (ScaleRadial()
          ..domain = [0, 0]
          ..range = [2, 1])(1),
        1.5811388300841898);
  });

  test(
      "radial(x) can map a bilinear domain with two values to the corresponding range",
      () {
    final s = ScaleRadial()..domain = [1, 2];
    expect(s.domain, [1, 2]);
    expect(s(0.5), -0.7071067811865476);
    expect(s(1.0), 0.0);
    expect(s(1.5), 0.7071067811865476);
    expect(s(2.0), 1.0);
    expect(s(2.5), 1.224744871391589);
    expect(s.invert(-0.5), 0.75);
    expect(s.invert(0.0), 1.0);
    expect(s.invert(0.5), 1.25);
    expect(s.invert(1.0), 2.0);
    expect(s.invert(1.5), 3.25);
  });

  test("radial(NaN) returns undefined", () {
    final s = ScaleRadial();
    expect(s(double.nan), null);
    expect(s(null), null);
  });

  test("radial.unknown(unknown)(NaN) returns the specified unknown value", () {
    expect((ScaleRadial()..unknown = 10)(double.nan), 10);
  });

  test("radial(x) can handle a negative range", () {
    expect(ScaleRadial(range: [-1, -2])(0.5), -1.5811388300841898);
  });

  test("radial(x) can clamp negative values", () {
    expect((ScaleRadial(range: [-1, -2])..clamp = true)(-0.5), -1);
    expect((ScaleRadial()..clamp = true)(-0.5), 0);
    expect((ScaleRadial(domain: [-0.25, 0], range: [1, 2])..clamp = true)(-0.5),
        1);
  });
}
