import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

import 'round_epsilon.dart';

void main() {
  test("ScaleLinear.dynamic() has the expected defaults", () {
    final s = ScaleLinear.dynamic();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
    expect(s.clamp, false);
    expect(s.unknown, null);
    expect(s.interpolate(0, 1)(0.5), 0.5);
  });

  test("ScaleLinear.dynamic(range: range) sets the range", () {
    final s = ScaleLinear.dynamic(range: [1, 2]);
    expect(s.domain, [0, 1]);
    expect(s.range, [1, 2]);
    expect(s(0.5), 1.5);
  });

  test(
      "ScaleLinear.dynamic(domain: domain, range: range) sets the domain and range",
      () {
    final s = ScaleLinear.dynamic(domain: [1, 2], range: [3, 4]);
    expect(s.domain, [1, 2]);
    expect(s.range, [3, 4]);
    expect(s(1.5), 3.5);
  });

  test("linear(x) maps a domain value x to a range value y", () {
    expect((ScaleLinear.dynamic()..range = [1, 2])(0.5), 1.5);
  });

  test(
      "linear(x) ignores extra range values if the domain is smaller than the range",
      () {
    expect(
        (ScaleLinear.dynamic()
          ..domain = [-10, 0]
          ..range = [0, 1, 2]
          ..clamp = true)(-5),
        0.5);
    expect(
        (ScaleLinear.dynamic()
          ..domain = [-10, 0]
          ..range = [0, 1, 2]
          ..clamp = true)(50),
        1);
  });

  test(
      "linear(x) ignores extra domain values if the range is smaller than the domain",
      () {
    expect(
        (ScaleLinear.dynamic()
          ..domain = [-10, 0, 100]
          ..range = [0, 1]
          ..clamp = true)(-5),
        0.5);
    expect(
        (ScaleLinear.dynamic()
          ..domain = [-10, 0, 100]
          ..range = [0, 1]
          ..clamp = true)(50),
        1);
  });

  test("linear(x) maps an empty domain to the middle of the range", () {
    expect(
        (ScaleLinear.dynamic()
          ..domain = [0, 0]
          ..range = [1, 2])(0),
        1.5);
    expect(
        (ScaleLinear.dynamic()
          ..domain = [0, 0]
          ..range = [2, 1])(1),
        1.5);
  });

  test(
      "linear(x) can map a bilinear domain with two values to the corresponding range",
      () {
    /*final s = ScaleLinear.dynamic()..domain = [1, 2];
    expect(s.domain, [1, 2]);
    expect(s(0.5), -0.5);
    expect(s(1.0), 0.0);
    expect(s(1.5), 0.5);
    expect(s(2.0), 1.0);
    expect(s(2.5), 1.5);
    expect(s.invert(-0.5), 0.5);
    expect(s.invert(0.0), 1.0);
    expect(s.invert(0.5), 1.5);
    expect(s.invert(1.0), 2.0);
    expect(s.invert(1.5), 2.5);*/
  });

  test(
      "linear(x) can map a polylinear domain with more than two values to the corresponding range",
      () {
    var s = ScaleLinear.dynamic()
      ..domain = [-10, 0, 100]
      ..range = ["red", "white", "green"];
    expect(s.domain, [-10, 0, 100]);
    expect(s(-5), "rgb(255, 128, 128)");
    expect(s(50), "rgb(128, 192, 128)");
    expect(s(75), "rgb(64, 160, 64)");

    s = ScaleLinear.number()
      ..domain = [4, 2, 1]
      ..range = [1, 2, 4];
    expect(s(1.5), 3);
    expect(s(3), 1.5);
    expect((s as ScaleLinear<num>).invert(1.5), 3);
    expect(s.invert(3), 1.5);
    s
      ..domain = [1, 2, 4]
      ..range = [4, 2, 1];
    expect(s(1.5), 3);
    expect(s(3), 1.5);
    expect(s.invert(1.5), 3);
    expect(s.invert(3), 1.5);
  });

  test("linear.invert(y) maps a range value y to a domain value x", () {
    expect((ScaleLinear.number()..range = [1, 2]).invert(1.5), 0.5);
  });

  test("linear.invert(y) maps an empty range to the middle of the domain", () {
    expect(
        (ScaleLinear.number()
              ..domain = [1, 2]
              ..range = [0, 0])
            .invert(0),
        1.5);
    expect(
        (ScaleLinear.number()
              ..domain = [2, 1]
              ..range = [0, 0])
            .invert(1),
        1.5);
  });

  test("linear.domain = domain accepts an array of numbers", () {
    expect((ScaleLinear.dynamic()..domain = []).domain, []);
    expect((ScaleLinear.dynamic()..domain = [1, 0]).domain, [1, 0]);
    expect((ScaleLinear.dynamic()..domain = [1, 2, 3]).domain, [1, 2, 3]);
  });

  /*test("linear.domain(domain) accepts an iterable", () {
    expect(scaleLinear().domain(new Set([1, 2])).domain(), [1, 2]);
  });*/

  test("linear.domain = domain makes a copy of domain values", () {
    final d = [1, 2], s = ScaleLinear.dynamic()..domain = d;
    expect(s.domain, [1, 2]);
    d.add(3);
    expect(s.domain, [1, 2]);
    expect(d, [1, 2, 3]);
  });

  test("linear.domain returns a copy of domain values", () {
    final s = ScaleLinear.dynamic(), d = s.domain;
    expect(d, [0, 1]);
    d.add(3);
    expect(s.domain, [0, 1]);
  });

  test("linear.range = range does not coerce range to numbers", () {
    final s = ScaleLinear.dynamic()..range = ["0px", "2px"];
    expect(s.range, ["0px", "2px"]);
    expect(s(0.5), "1.0px");
  });

  /*test("linear.range = range accepts an iterable", () {
    expect((ScaleLinear.dynamic()..range = new Set([1, 2])).range, [1, 2]);
  });*/

  test("linear.range = range can accept range values as colors", () {
    expect((ScaleLinear.dynamic()..range = ["red", "blue"])(0.5),
        "rgb(128, 0, 128)");
    expect((ScaleLinear.dynamic()..range = ["#ff0000", "#0000ff"])(0.5),
        "rgb(128, 0, 128)");
    expect((ScaleLinear.dynamic()..range = ["#f00", "#00f"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScaleLinear.dynamic()
          ..range = ["rgb(255,0,0)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScaleLinear.dynamic()
          ..range = ["rgb(100%,0%,0%)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScaleLinear.dynamic()
          ..range = ["hsl(0,100%,50%)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
  });

  test("linear.range = range can accept range values as arrays or objects", () {
    expect(
        (ScaleLinear.dynamic()
          ..range = [
            {"color": "red"},
            {"color": "blue"}
          ])(0.5),
        {"color": "rgb(128, 0, 128)"});
    expect(
        (ScaleLinear.dynamic()
          ..range = [
            ["red"],
            ["blue"]
          ])(0.5),
        ["rgb(128, 0, 128)"]);
  });

  test("linear.range = range makes a copy of range values", () {
    final r = [1, 2], s = ScaleLinear.dynamic()..range = r;
    expect(s.range, [1, 2]);
    r.add(3);
    expect(s.range, [1, 2]);
    expect(r, [1, 2, 3]);
  });

  test("linear.range returns a copy of range values", () {
    final s = ScaleLinear.dynamic(), r = s.range;
    expect(r, [0, 1]);
    r.add(3);
    expect(s.range, [0, 1]);
  });

  test(
      "linear.rangeRound(range) is an alias for linear.range(range).interpolate(interpolateRound)",
      () {
    expect((ScaleLinear.number()..rangeRound([0, 10]))(0.59), 6);
  });

  /*test("linear.rangeRound(range) accepts an iterable", () {
    expect((ScaleLinear.number()..rangeRound(new Set([1, 2]))).range, [1, 2]);
  });*/

  test(
      "linear.unknown = value sets the return value for undefined, null, and NaN input",
      () {
    final s = ScaleLinear.dynamic()..unknown = -1;
    expect(s(null), -1);
    expect(s(double.nan), -1);
    expect(s(0.4), 0.4);
  });

  test("linear.clamp is false by default", () {
    expect(ScaleLinear.dynamic().clamp, false);
    expect((ScaleLinear.dynamic()..range = [10, 20])(2), 30);
    expect((ScaleLinear.dynamic()..range = [10, 20])(-1), 0);
    expect((ScaleLinear.number()..range = [10, 20]).invert(30), 2);
    expect((ScaleLinear.number()..range = [10, 20]).invert(0), -1);
  });

  test("linear.clamp = true restricts output values to the range", () {
    expect(
        (ScaleLinear.dynamic()
          ..clamp = true
          ..range = [10, 20])(2),
        20);
    expect(
        (ScaleLinear.dynamic()
          ..clamp = true
          ..range = [10, 20])(-1),
        10);
  });

  test("linear.clamp = true restricts input values to the domain", () {
    expect(
        (ScaleLinear.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(30),
        1);
    expect(
        (ScaleLinear.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(0),
        0);
  });

  test("linear.interpolate = interpolate takes a custom interpolator factory",
      () {
    interpolate(a, b) {
      return (t) {
        return [a, b, t];
      };
    }

    final s = ScaleLinear.dynamic()
      ..domain = [10, 20]
      ..range = ["a", "b"]
      ..interpolate = interpolate;
    expect(s.interpolate, interpolate);
    expect(s(15), ["a", "b", 0.5]);
  });

  test("linear.nice() is an alias for linear.nice(10)", () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 0.96]
              ..nice())
            .domain,
        [0, 1]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 96]
              ..nice())
            .domain,
        [0, 100]);
  });

  test("linear.nice(count) extends the domain to match the desired ticks", () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 0.96]
              ..nice(10))
            .domain,
        [0, 1]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 96]
              ..nice(10))
            .domain,
        [0, 100]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0.96, 0]
              ..nice(10))
            .domain,
        [1, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [96, 0]
              ..nice(10))
            .domain,
        [100, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, -0.96]
              ..nice(10))
            .domain,
        [0, -1]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, -96]
              ..nice(10))
            .domain,
        [0, -100]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [-0.96, 0]
              ..nice(10))
            .domain,
        [-1, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [-96, 0]
              ..nice(10))
            .domain,
        [-100, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [-0.1, 51.1]
              ..nice(8))
            .domain,
        [-10, 60]);
  });

  test("linear.nice(count) nices the domain, extending it to round numbers",
      () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [1.1, 10.9]
              ..nice(10))
            .domain,
        [1, 11]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [10.9, 1.1]
              ..nice(10))
            .domain,
        [11, 1]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0.7, 11.001]
              ..nice(10))
            .domain,
        [0, 12]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [123.1, 6.7]
              ..nice(10))
            .domain,
        [130, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 0.49]
              ..nice(10))
            .domain,
        [0, 0.5]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 14.1]
              ..nice(5))
            .domain,
        [0, 20]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 15]
              ..nice(5))
            .domain,
        [0, 20]);
  });

  test("linear.nice(count) has no effect on degenerate domains", () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0, 0]
              ..nice(10))
            .domain,
        [0, 0]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [0.5, 0.5]
              ..nice(10))
            .domain,
        [0.5, 0.5]);
  });

  test("linear.nice(count) nicing a polylinear domain only affects the extent",
      () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [1.1, 1, 2, 3, 10.9]
              ..nice(10))
            .domain,
        [1, 1, 2, 3, 11]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [123.1, 1, 2, 3, -0.9]
              ..nice(10))
            .domain,
        [130, 1, 2, 3, -10]);
  });

  test("linear.nice(count) accepts a tick count to control nicing step", () {
    expect(
        (ScaleLinear.dynamic()
              ..domain = [12, 87]
              ..nice(5))
            .domain,
        [0, 100]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [12, 87]
              ..nice(10))
            .domain,
        [10, 90]);
    expect(
        (ScaleLinear.dynamic()
              ..domain = [12, 87]
              ..nice(100))
            .domain,
        [12, 87]);
  });

  test("linear.ticks(count) returns the expected ticks for an ascending domain",
      () {
    final s = ScaleLinear.dynamic();
    expect(s.ticks(10).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(9).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(8).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(7).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(6).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(5).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(4).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(3).map(roundEpsilon), [0.0, 0.5, 1.0]);
    expect(s.ticks(2).map(roundEpsilon), [0.0, 0.5, 1.0]);
    expect(s.ticks(1).map(roundEpsilon), [0.0, 1.0]);
    s.domain = [-100, 100];
    expect(s.ticks(10), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(9), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(8), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(7), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(6), [-100, -50, 0, 50, 100]);
    expect(s.ticks(5), [-100, -50, 0, 50, 100]);
    expect(s.ticks(4), [-100, -50, 0, 50, 100]);
    expect(s.ticks(3), [-100, -50, 0, 50, 100]);
    expect(s.ticks(2), [-100, 0, 100]);
    expect(s.ticks(1), [0]);
  });

  test("linear.ticks(count) returns the expected ticks for a descending domain",
      () {
    final s = ScaleLinear.dynamic()..domain = [1, 0];
    expect(s.ticks(10).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0].reversed);
    expect(s.ticks(9).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0].reversed);
    expect(s.ticks(8).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0].reversed);
    expect(
        s.ticks(7).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].reversed);
    expect(
        s.ticks(6).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].reversed);
    expect(
        s.ticks(5).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].reversed);
    expect(
        s.ticks(4).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].reversed);
    expect(s.ticks(3).map(roundEpsilon), [0.0, 0.5, 1.0].reversed);
    expect(s.ticks(2).map(roundEpsilon), [0.0, 0.5, 1.0].reversed);
    expect(s.ticks(1).map(roundEpsilon), [0.0, 1.0].reversed);
    s.domain = [100, -100];
    expect(s.ticks(10),
        [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100].reversed);
    expect(s.ticks(9),
        [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100].reversed);
    expect(s.ticks(8),
        [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100].reversed);
    expect(s.ticks(7),
        [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100].reversed);
    expect(s.ticks(6), [-100, -50, 0, 50, 100].reversed);
    expect(s.ticks(5), [-100, -50, 0, 50, 100].reversed);
    expect(s.ticks(4), [-100, -50, 0, 50, 100].reversed);
    expect(s.ticks(3), [-100, -50, 0, 50, 100].reversed);
    expect(s.ticks(2), [-100, 0, 100].reversed);
    expect(s.ticks(1), [0].reversed);
  });

  test("linear.ticks(count) returns the expected ticks for a polylinear domain",
      () {
    final s = ScaleLinear.dynamic()..domain = [0, 0.25, 0.9, 1];
    expect(s.ticks(10).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(9).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(8).map(roundEpsilon),
        [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
    expect(s.ticks(7).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(6).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(5).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(4).map(roundEpsilon), [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    expect(s.ticks(3).map(roundEpsilon), [0.0, 0.5, 1.0]);
    expect(s.ticks(2).map(roundEpsilon), [0.0, 0.5, 1.0]);
    expect(s.ticks(1).map(roundEpsilon), [0.0, 1.0]);
    s.domain = [-100, 0, 100];
    expect(s.ticks(10), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(9), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(8), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(7), [-100, -80, -60, -40, -20, 0, 20, 40, 60, 80, 100]);
    expect(s.ticks(6), [-100, -50, 0, 50, 100]);
    expect(s.ticks(5), [-100, -50, 0, 50, 100]);
    expect(s.ticks(4), [-100, -50, 0, 50, 100]);
    expect(s.ticks(3), [-100, -50, 0, 50, 100]);
    expect(s.ticks(2), [-100, 0, 100]);
    expect(s.ticks(1), [0]);
  });

  test("linear.ticks(X) spans (linear..nice(X)).domain", () {
    check(domain, count) {
      final s = ScaleLinear.dynamic()
        ..domain = domain
        ..nice(count);
      final ticks = s.ticks(count);
      expect([ticks[0], ticks[ticks.length - 1]], s.domain);
    }

    check([1, 9], 2);
    check([1, 9], 3);
    check([1, 9], 4);
    check([8, 9], 2);
    check([8, 9], 3);
    check([8, 9], 4);
    check([1, 21], 2);
    check([2, 21], 2);
    check([3, 21], 2);
    check([4, 21], 2);
    check([5, 21], 2);
    check([6, 21], 2);
    check([7, 21], 2);
    check([8, 21], 2);
    check([9, 21], 2);
    check([10, 21], 2);
    check([11, 21], 2);
  });

  test(
      "linear.ticks(count) returns the empty array if count is not a positive integer",
      () {
    final s = ScaleLinear.dynamic();
    expect(s.ticks(double.nan), []);
    expect(s.ticks(0), []);
    expect(s.ticks(-1), []);
    expect(s.ticks(double.infinity), []);
  });

  test("linear.ticks() is an alias for linear.ticks(10)", () {
    final s = ScaleLinear.dynamic();
    expect(s.ticks(), s.ticks(10));
  });

  test("linear.tickFormat() is an alias for linear.tickFormat(10)", () {
    expect(ScaleLinear.dynamic().tickFormat()(0.2), "0.2");
    expect(
        (ScaleLinear.dynamic()..domain = [-100, 100]).tickFormat()(-20), "−20");
  });

  test("linear.tickFormat(count) returns a format suitable for the ticks", () {
    expect(ScaleLinear.dynamic().tickFormat(10)(0.2), "0.2");
    expect(ScaleLinear.dynamic().tickFormat(20)(0.2), "0.20");
    expect((ScaleLinear.dynamic()..domain = [-100, 100]).tickFormat(10)(-20),
        "−20");
  });

  test(
      "linear.tickFormat(count, specifier) sets the appropriate fixed precision if not specified",
      () {
    expect(ScaleLinear.dynamic().tickFormat(10, "+f")(0.2), "+0.2");
    expect(ScaleLinear.dynamic().tickFormat(20, "+f")(0.2), "+0.20");
    expect(ScaleLinear.dynamic().tickFormat(10, "+%")(0.2), "+20%");
    expect(
        (ScaleLinear.dynamic()..domain = [0.19, 0.21])
            .tickFormat(10, "+%")(0.2),
        "+20.0%");
  });

  test(
      "linear.tickFormat(count, specifier) sets the appropriate round precision if not specified",
      () {
    expect(
        (ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(10, "")(2.10), "2");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "")(2.01),
        "2");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "")(2.11),
        "2.1");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(10, "e")(2.10),
        "2e+0");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "e")(2.01),
        "2.0e+0");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "e")(2.11),
        "2.1e+0");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(10, "g")(2.10),
        "2");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "g")(2.01),
        "2.0");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "g")(2.11),
        "2.1");
    expect((ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(10, "r")(2.10e6),
        "2000000");
    expect(
        (ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "r")(2.01e6),
        "2000000");
    expect(
        (ScaleLinear.dynamic()..domain = [0, 9]).tickFormat(100, "r")(2.11e6),
        "2100000");
    expect(
        (ScaleLinear.dynamic()..domain = [0, 0.9]).tickFormat(10, "p")(0.210),
        "20%");
    expect(
        (ScaleLinear.dynamic()..domain = [0.19, 0.21])
            .tickFormat(10, "p")(0.201),
        "20.1%");
  });

  test(
      "linear.tickFormat(count, specifier) sets the appropriate prefix precision if not specified",
      () {
    expect(
        (ScaleLinear.dynamic()..domain = [0, 1000000])
            .tickFormat(10, "\$s")(510000),
        "\$0.5M");
    expect(
        (ScaleLinear.dynamic()..domain = [0, 1000000])
            .tickFormat(100, "\$s")(501000),
        "\$0.50M");
  });

  test(
      "linear.tickFormat() uses the default precision when the domain is invalid",
      () {
    final f = (ScaleLinear.dynamic()..domain = [0, double.nan]).tickFormat();
    expect(f(0.12), "0.120000");
  });

  test("linear.copy() returns a copy with changes to the domain are isolated",
      () {
    final x = ScaleLinear.dynamic(), y = x.copy();
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

  test("linear.copy() returns a copy with changes to the range are isolated",
      () {
    final x = ScaleLinear.number(), y = x.copy();
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

  test(
      "linear.copy() returns a copy with changes to the interpolator are isolated",
      () {
    final x = ScaleLinear.dynamic()..range = ["red", "blue"];
    final y = x.copy();
    final i0 = x.interpolate;
    i1(a, b) {
      return (_) {
        return b;
      };
    }

    x.interpolate = i1;
    expect(y.interpolate, i0);
    expect(x(0.5), "blue");
    expect(y(0.5), "rgb(128, 0, 128)");
  });

  test("linear.copy() returns a copy with changes to clamping are isolated",
      () {
    final x = ScaleLinear.dynamic()..clamp = true, y = x.copy();
    x.clamp = false;
    expect(x(2), 2);
    expect(y(2), 1);
    expect(y.clamp, true);
    y.clamp = false;
    expect(x(2), 2);
    expect(y(2), 2);
    expect(x.clamp, false);
  });

  test(
      "linear.copy() returns a copy with changes to the unknown value are isolated",
      () {
    final x = ScaleLinear.dynamic(), y = x.copy();
    x.unknown = 2;
    expect(x(double.nan), 2);
    expect(y(double.nan), null);
    expect(y.unknown, null);
    y.unknown = 3;
    expect(x(double.nan), 2);
    expect(y(double.nan), 3);
    expect(x.unknown, 2);
  });
}
