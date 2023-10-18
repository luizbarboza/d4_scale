import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleSymlog.dynamic() has the expected defaults", () {
    final s = ScaleSymlog.dynamic();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
    expect(s.clamp, false);
    expect(s.constant, 1);
  });

  test("symlog(x) maps a domain value x to a range value y", () {
    final s = ScaleSymlog.dynamic()..domain = [-100, 100];
    expect(s(-100), 0);
    expect(s(100), 1);
    expect(s(0), 0.5);
  });

  test("symlog.invert(y) maps a range value y to a domain value x", () {
    final s = ScaleSymlog.number()..domain = [-100, 100];
    expect(s.invert(1), closeTo(100, 1e-6));
  });

  test("symlog.constant(constant) sets the constant to the specified value",
      () {
    final s = ScaleSymlog.dynamic()..constant = 5;
    expect(s.constant, 5);
  });

  test(
      "symlog.constant(constant) changing the constant does not change the domain or range",
      () {
    final s = ScaleSymlog.dynamic()..constant = 2;
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
  });

  test("symlog.domain(domain) accepts an array of numbers", () {
    expect((ScaleSymlog.dynamic()..domain = []).domain, []);
    expect((ScaleSymlog.dynamic()..domain = [1, 0]).domain, [1, 0]);
    expect((ScaleSymlog.dynamic()..domain = [1, 2, 3]).domain, [1, 2, 3]);
  });

  test("symlog.domain(domain) makes a copy of domain values", () {
    final d = [1, 2], s = ScaleSymlog.dynamic()..domain = d;
    expect(s.domain, [1, 2]);
    d.add(3);
    expect(s.domain, [1, 2]);
    expect(d, [1, 2, 3]);
  });

  test("symlog.domain() returns a copy of domain values", () {
    final s = ScaleSymlog.dynamic(), d = s.domain;
    expect(d, [0, 1]);
    d.add(3);
    expect(s.domain, [0, 1]);
  });

  test("symlog.range(range) does not coerce range to numbers", () {
    final s = ScaleSymlog.dynamic()..range = ["0px", "2px"];
    expect(s.range, ["0px", "2px"]);
    expect(s(1), "2.0px");
  });

  test("symlog.range(range) can accept range values as arrays or objects", () {
    expect(
        (ScaleSymlog.dynamic()
          ..range = [
            {"color": "red"},
            {"color": "blue"}
          ])(1),
        {"color": "rgb(0, 0, 255)"});
    expect(
        (ScaleSymlog.dynamic()
          ..range = [
            ["red"],
            ["blue"]
          ])(0),
        ["rgb(255, 0, 0)"]);
  });

  test("symlog.range(range) makes a copy of range values", () {
    final r = [1, 2], s = ScaleSymlog.dynamic()..range = r;
    expect(s.range, [1, 2]);
    r.add(3);
    expect(s.range, [1, 2]);
    expect(r, [1, 2, 3]);
  });

  test("symlog.range() returns a copy of range values", () {
    final s = ScaleSymlog.dynamic(), r = s.range;
    expect(r, [0, 1]);
    r.add(3);
    expect(s.range, [0, 1]);
  });

  test("symlog.clamp() is false by default", () {
    expect(ScaleSymlog.dynamic().clamp, false);
    expect((ScaleSymlog.dynamic()..range = [10, 20])(3), 30);
    expect((ScaleSymlog.dynamic()..range = [10, 20])(-1), 0);
    expect((ScaleSymlog.number()..range = [10, 20]).invert(30), 3);
    expect((ScaleSymlog.number()..range = [10, 20]).invert(0), -1);
  });

  test("symlog.clamp(true) restricts output values to the range", () {
    expect(
        (ScaleSymlog.number()
          ..clamp = true
          ..range = [10, 20])(2),
        20);
    expect(
        (ScaleSymlog.number()
          ..clamp = true
          ..range = [10, 20])(-1),
        10);
  });

  test("symlog.clamp(true) restricts input values to the domain", () {
    expect(
        (ScaleSymlog.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(30),
        1);
    expect(
        (ScaleSymlog.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(0),
        0);
  });

  test("symlog.copy() returns a copy with changes to the domain are isolated",
      () {
    final x = ScaleSymlog.dynamic(), y = x.copy();
    x.domain = [1, 2];
    expect(y.domain, [0, 1]);
    expect(x(1), 0);
    expect(y(1), 1);
    y.domain = [2, 3];
    expect(x(2), 1);
    expect(y(2), 0);
    expect(x.domain, [1, 2]);
    expect(y.domain, [2, 3]);
    final y2 = (x..domain = [1, 1.9]).copy();
    x.nice(5);
    expect(x.domain, [1, 2]);
    expect(y2.domain, [1, 1.9]);
  });

  test("symlog.copy() returns a copy with changes to the range are isolated",
      () {
    final x = ScaleSymlog.number(), y = x.copy();
    x.range = [1, 2];
    expect(x.invert(1), 0);
    expect(y.invert(1), 1);
    expect(y.range, [0, 1]);
    y.range = [2, 3];
    expect(x.invert(2), 1);
    expect(y.invert(2), 0);
    expect(x.range, [1, 2]);
    expect(y.range, [2, 3]);
  });

  test("symlog.copy() returns a copy with changes to clamping are isolated",
      () {
    final x = ScaleSymlog.number()..clamp = true, y = x.copy();
    x.clamp = false;
    expect(x(3), 2);
    expect(y(2), 1);
    expect(y.clamp, true);
    y.clamp = false;
    expect(x(3), 2);
    expect(y(3), 2);
    expect(x.clamp, false);
  });

  test(
      "symlog().clamp(true).invert(x) cannot return a value outside the domain",
      () {
    final x = ScaleSymlog.number()
      ..domain = [1, 20]
      ..clamp = true;
    expect(x.invert(0), 1);
    expect(x.invert(1), 20);
  });
}
