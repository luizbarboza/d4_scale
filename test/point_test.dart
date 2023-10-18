import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("scalePoint() has the expected defaults", () {
    final s = ScalePoint();
    expect(s.domain, []);
    expect(s.range, [0, 1]);
    expect(s.bandwidth, 0);
    expect(s.step, 1);
    expect(s.round, false);
    expect(s.padding, 0);
    expect(s.align, 0.5);
  });

  test("scalePoint() is similar to scaleBand().paddingInner(1)", () {
    final p = ScalePoint()
      ..domain = ["foo", "bar"]
      ..range = [0, 960];
    final b = ScaleBand()
      ..domain = ["foo", "bar"]
      ..range = [0, 960]
      ..paddingInner = 1;
    expect(p.domain.map(p), b.domain.map(b));
    expect(p.bandwidth, b.bandwidth);
    expect(p.step, b.step);
  });

  test("point.padding(p) sets the band outer padding to p", () {
    final p = ScalePoint()
      ..domain = ["foo", "bar"]
      ..range = [0, 960]
      ..padding = 0.5;
    final b = ScaleBand()
      ..domain = ["foo", "bar"]
      ..range = [0, 960]
      ..paddingInner = 1
      ..paddingOuter = 0.5;
    expect(p.domain.map(p), b.domain.map(b));
    expect(p.bandwidth, b.bandwidth);
    expect(p.step, b.step);
  });

  test("point.copy() returns a copy", () {
    final s = ScalePoint();
    expect(s.domain, []);
    expect(s.range, [0, 1]);
    expect(s.bandwidth, 0);
    expect(s.step, 1);
    expect(s.round, false);
    expect(s.padding, 0);
    expect(s.align, 0.5);
  });
}
