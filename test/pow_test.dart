import 'dart:math';

import 'package:d4_interpolate/d4_interpolate.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

import 'round_epsilon.dart';

void main() {
  test("scalePow() has the expected defaults", () {
    final s = ScalePow.dynamic();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
    expect(s.clamp, false);
    expect(s.exponent, 1);
    expect(
        s.interpolate({
          "array": ["red"]
        }, {
          "array": ["blue"]
        })(0.5),
        {
          "array": ["rgb(128, 0, 128)"]
        });
  });

  test("pow(x) maps a domain value x to a range value y", () {
    expect((ScalePow.dynamic()..exponent = 0.5)(0.5), sqrt1_2);
  });

  test(
      "pow(x) ignores extra range values if the domain is smaller than the range",
      () {
    expect(
        (ScalePow.dynamic()
          ..domain = [-10, 0]
          ..range = ["red", "white", "green"]
          ..clamp = true)(-5),
        "rgb(255, 128, 128)");
    expect(
        (ScalePow.dynamic()
          ..domain = [-10, 0]
          ..range = ["red", "white", "green"]
          ..clamp = true)(50),
        "rgb(255, 255, 255)");
  });

  test(
      "pow(x) ignores extra domain values if the range is smaller than the domain",
      () {
    expect(
        (ScalePow.dynamic()
          ..domain = [-10, 0, 100]
          ..range = ["red", "white"]
          ..clamp = true)(-5),
        "rgb(255, 128, 128)");
    expect(
        (ScalePow.dynamic()
          ..domain = [-10, 0, 100]
          ..range = ["red", "white"]
          ..clamp = true)(50),
        "rgb(255, 255, 255)");
  });

  test("pow(x) maps an empty domain to the middle of the range", () {
    expect(
        (ScalePow.dynamic()
          ..domain = [0, 0]
          ..range = [1, 2])(0),
        1.5);
    expect(
        (ScalePow.dynamic()
          ..domain = [0, 0]
          ..range = [2, 1])(1),
        1.5);
  });

  test(
      "pow(x) can map a bipow domain with two values to the corresponding range",
      () {
    final s = ScalePow.number()..domain = [1, 2];
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
    expect(s.invert(1.5), 2.5);
  });

  test(
      "pow(x) can map a polypow domain with more than two values to the corresponding range",
      () {
    var s = ScalePow.dynamic()
      ..domain = [-10, 0, 100]
      ..range = ["red", "white", "green"];
    expect(s.domain, [-10, 0, 100]);
    expect(s(-5), "rgb(255, 128, 128)");
    expect(s(50), "rgb(128, 192, 128)");
    expect(s(75), "rgb(64, 160, 64)");
    s = ScalePow.number()
      ..domain = [4, 2, 1]
      ..range = [1, 2, 4];
    expect(s(1.5), 3);
    expect(s(3), 1.5);
    expect((s as ScalePow<num>).invert(1.5), 3);
    expect(s.invert(3), 1.5);
    s
      ..domain = [1, 2, 4]
      ..range = [4, 2, 1];
    expect(s(1.5), 3);
    expect(s(3), 1.5);
    expect(s.invert(1.5), 3);
    expect(s.invert(3), 1.5);
  });

  test("pow.invert(y) maps a range value y to a domain value x", () {
    expect((ScalePow.number()..range = [1, 2]).invert(1.5), 0.5);
  });

  test("pow.invert(y) maps an empty range to the middle of the domain", () {
    expect(
        (ScalePow.number()
              ..domain = [1, 2]
              ..range = [0, 0])
            .invert(0),
        1.5);
    expect(
        (ScalePow.number()
              ..domain = [2, 1]
              ..range = [0, 0])
            .invert(1),
        1.5);
  });

  test("pow.exponent = exponent sets the exponent to the specified value", () {
    final x = ScalePow.dynamic()
      ..exponent = 0.5
      ..domain = [1, 2];
    expect(x(1), closeTo(0, 1e-6));
    expect(x(1.5), closeTo(0.5425821, 1e-6));
    expect(x(2), closeTo(1, 1e-6));
    expect(x.exponent, 0.5);
    x
      ..exponent = 2
      ..domain = [1, 2];
    expect(x(1), closeTo(0, 1e-6));
    expect(x(1.5), closeTo(0.41666667, 1e-6));
    expect(x(2), closeTo(1, 1e-6));
    expect(x.exponent, 2);
    x
      ..exponent = -1
      ..domain = [1, 2];
    expect(x(1), closeTo(0, 1e-6));
    expect(x(1.5), closeTo(0.6666667, 1e-6));
    expect(x(2), closeTo(1, 1e-6));
    expect(x.exponent, -1);
  });

  test(
      "pow.exponent = exponent changing the exponent does not change the domain or range",
      () {
    final x = ScalePow.dynamic()
      ..domain = [1, 2]
      ..range = [3, 4];
    x.exponent = 0.5;
    expect(x.domain, [1, 2]);
    expect(x.range, [3, 4]);
    x.exponent = 2;
    expect(x.domain, [1, 2]);
    expect(x.range, [3, 4]);
    x.exponent = -1;
    expect(x.domain, [1, 2]);
    expect(x.range, [3, 4]);
  });

  test("pow.domain = domain accepts an array of numbers", () {
    expect((ScalePow.dynamic()..domain = []).domain, []);
    expect((ScalePow.dynamic()..domain = [1, 0]).domain, [1, 0]);
    expect((ScalePow.dynamic()..domain = [1, 2, 3]).domain, [1, 2, 3]);
  });

  test("pow.domain = domain makes a copy of domain values", () {
    final d = [1, 2], s = ScalePow.dynamic()..domain = d;
    expect(s.domain, [1, 2]);
    d.add(3);
    expect(s.domain, [1, 2]);
    expect(d, [1, 2, 3]);
  });

  test("pow.domain returns a copy of domain values", () {
    final s = ScalePow.dynamic(), d = s.domain;
    expect(d, [0, 1]);
    d.add(3);
    expect(s.domain, [0, 1]);
  });

  test("pow.range = range does not coerce range to numbers", () {
    final s = ScalePow.dynamic()..range = ["0px", "2px"];
    expect(s.range, ["0px", "2px"]);
    expect(s(0.5), "1.0px");
  });

  test("pow.range = range can accept range values as colors", () {
    expect(
        (ScalePow.dynamic()..range = ["red", "blue"])(0.5), "rgb(128, 0, 128)");
    expect((ScalePow.dynamic()..range = ["#ff0000", "#0000ff"])(0.5),
        "rgb(128, 0, 128)");
    expect((ScalePow.dynamic()..range = ["#f00", "#00f"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScalePow.dynamic()
          ..range = ["rgb(255,0,0)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScalePow.dynamic()
          ..range = ["rgb(100%,0%,0%)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
    expect(
        (ScalePow.dynamic()
          ..range = ["hsl(0,100%,50%)", "hsl(240,100%,50%)"])(0.5),
        "rgb(128, 0, 128)");
  });

  test("pow.range = range can accept range values as arrays or objects", () {
    expect(
        (ScalePow.dynamic()
          ..range = [
            {"color": "red"},
            {"color": "blue"}
          ])(0.5),
        {"color": "rgb(128, 0, 128)"});
    expect(
        (ScalePow.dynamic()
          ..range = [
            ["red"],
            ["blue"]
          ])(0.5),
        ["rgb(128, 0, 128)"]);
  });

  test("pow.range = range makes a copy of range values", () {
    final r = [1, 2], s = ScalePow.dynamic()..range = r;
    expect(s.range, [1, 2]);
    r.add(3);
    expect(s.range, [1, 2]);
    expect(r, [1, 2, 3]);
  });

  test("pow.range returns a copy of range values", () {
    final s = ScalePow.dynamic(), r = s.range;
    expect(r, [0, 1]);
    r.add(3);
    expect(s.range, [0, 1]);
  });

  test(
      "pow.rangeRound(range) is an alias for pow.range(range).interpolate(interpolateRound)",
      () {
    expect((ScalePow.number()..rangeRound([0, 10]))(0.59), 6);
  });

  test("pow.clamp is false by default", () {
    expect(ScalePow.dynamic().clamp, false);
    expect((ScalePow.dynamic()..range = [10, 20])(2), 30);
    expect((ScalePow.dynamic()..range = [10, 20])(-1), 0);
    expect((ScalePow.number()..range = [10, 20]).invert(30), 2);
    expect((ScalePow.number()..range = [10, 20]).invert(0), -1);
  });

  test("pow.clamp = true restricts output values to the range", () {
    expect(
        (ScalePow.dynamic()
          ..clamp = true
          ..range = [10, 20])(2),
        20);
    expect(
        (ScalePow.dynamic()
          ..clamp = true
          ..range = [10, 20])(-1),
        10);
  });

  test("pow.clamp = true restricts input values to the domain", () {
    expect(
        (ScalePow.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(30),
        1);
    expect(
        (ScalePow.number()
              ..clamp = true
              ..range = [10, 20])
            .invert(0),
        0);
  });

  test("pow.interpolate = interpolate takes a custom interpolator factory", () {
    interpolate(a, b) {
      return (t) {
        return [a, b, t];
      };
    }

    final s = ScalePow.dynamic()
      ..domain = [10, 20]
      ..range = ["a", "b"]
      ..interpolate = interpolate;
    expect(s.interpolate, interpolate);
    expect(s(15), ["a", "b", 0.5]);
  });

  test("pow.nice() is an alias for pow.nice(10)", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 0.96]
              ..nice())
            .domain,
        [0, 1]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 96]
              ..nice())
            .domain,
        [0, 100]);
  });

  test("pow.nice(count) extends the domain to match the desired ticks", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 0.96]
              ..nice(10))
            .domain,
        [0, 1]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 96]
              ..nice(10))
            .domain,
        [0, 100]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0.96, 0]
              ..nice(10))
            .domain,
        [1, 0]);
    expect(
        (ScalePow.dynamic()
              ..domain = [96, 0]
              ..nice(10))
            .domain,
        [100, 0]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0, -0.96]
              ..nice(10))
            .domain,
        [0, -1]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0, -96]
              ..nice(10))
            .domain,
        [0, -100]);
    expect(
        (ScalePow.dynamic()
              ..domain = [-0.96, 0]
              ..nice(10))
            .domain,
        [-1, 0]);
    expect(
        (ScalePow.dynamic()
              ..domain = [-96, 0]
              ..nice(10))
            .domain,
        [-100, 0]);
  });

  test("pow.nice(count) nices the domain, extending it to round numbers", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [1.1, 10.9]
              ..nice(10))
            .domain,
        [1, 11]);
    expect(
        (ScalePow.dynamic()
              ..domain = [10.9, 1.1]
              ..nice(10))
            .domain,
        [11, 1]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0.7, 11.001]
              ..nice(10))
            .domain,
        [0, 12]);
    expect(
        (ScalePow.dynamic()
              ..domain = [123.1, 6.7]
              ..nice(10))
            .domain,
        [130, 0]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 0.49]
              ..nice(10))
            .domain,
        [0, 0.5]);
  });

  test("pow.nice(count) has no effect on degenerate domains", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [0, 0]
              ..nice(10))
            .domain,
        [0, 0]);
    expect(
        (ScalePow.dynamic()
              ..domain = [0.5, 0.5]
              ..nice(10))
            .domain,
        [0.5, 0.5]);
  });

  test("pow.nice(count) nicing a polypow domain only affects the extent", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [1.1, 1, 2, 3, 10.9]
              ..nice(10))
            .domain,
        [1, 1, 2, 3, 11]);
    expect(
        (ScalePow.dynamic()
              ..domain = [123.1, 1, 2, 3, -0.9]
              ..nice(10))
            .domain,
        [130, 1, 2, 3, -10]);
  });

  test("pow.nice(count) accepts a tick count to control nicing step", () {
    expect(
        (ScalePow.dynamic()
              ..domain = [12, 87]
              ..nice(5))
            .domain,
        [0, 100]);
    expect(
        (ScalePow.dynamic()
              ..domain = [12, 87]
              ..nice(10))
            .domain,
        [10, 90]);
    expect(
        (ScalePow.dynamic()
              ..domain = [12, 87]
              ..nice(100))
            .domain,
        [12, 87]);
  });

  test("pow.ticks(count) returns the expected ticks for an ascending domain",
      () {
    final s = ScalePow.dynamic();
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

  test("pow.ticks(count) returns the expected ticks for a descending domain",
      () {
    final s = ScalePow.dynamic()..domain = [1, 0];
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

  test("pow.ticks(count) returns the expected ticks for a polypow domain", () {
    final s = ScalePow.dynamic()..domain = [0, 0.25, 0.9, 1];
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

  test(
      "pow.ticks(count) returns the empty array if count is not a positive integer",
      () {
    final s = ScalePow.dynamic();
    expect(s.ticks(double.nan), []);
    expect(s.ticks(0), []);
    expect(s.ticks(-1), []);
    expect(s.ticks(double.infinity), []);
  });

  test("pow.ticks() is an alias for pow.ticks(10)", () {
    final s = ScalePow.dynamic();
    expect(s.ticks(), s.ticks(10));
  });

  test("pow.tickFormat() is an alias for pow.tickFormat(10)", () {
    expect(ScalePow.dynamic().tickFormat()(0.2), "0.2");
    expect((ScalePow.dynamic()..domain = [-100, 100]).tickFormat()(-20), "−20");
  });

  test("pow.tickFormat(count) returns a format suitable for the ticks", () {
    expect(ScalePow.dynamic().tickFormat(10)(0.2), "0.2");
    expect(ScalePow.dynamic().tickFormat(20)(0.2), "0.20");
    expect(
        (ScalePow.dynamic()..domain = [-100, 100]).tickFormat(10)(-20), "−20");
  });

  test(
      "pow.tickFormat(count, specifier) sets the appropriate fixed precision if not specified",
      () {
    expect(ScalePow.dynamic().tickFormat(10, "+f")(0.2), "+0.2");
    expect(ScalePow.dynamic().tickFormat(20, "+f")(0.2), "+0.20");
    expect(ScalePow.dynamic().tickFormat(10, "+%")(0.2), "+20%");
    expect(
        (ScalePow.dynamic()..domain = [0.19, 0.21]).tickFormat(10, "+%")(0.2),
        "+20.0%");
  });

  test(
      "pow.tickFormat(count, specifier) sets the appropriate round precision if not specified",
      () {
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(10, "")(2.10), "2");
    expect(
        (ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "")(2.01), "2");
    expect(
        (ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "")(2.11), "2.1");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(10, "e")(2.10),
        "2e+0");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "e")(2.01),
        "2.0e+0");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "e")(2.11),
        "2.1e+0");
    expect(
        (ScalePow.dynamic()..domain = [0, 9]).tickFormat(10, "g")(2.10), "2");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "g")(2.01),
        "2.0");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "g")(2.11),
        "2.1");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(10, "r")(2.10e6),
        "2000000");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "r")(2.01e6),
        "2000000");
    expect((ScalePow.dynamic()..domain = [0, 9]).tickFormat(100, "r")(2.11e6),
        "2100000");
    expect((ScalePow.dynamic()..domain = [0, 0.9]).tickFormat(10, "p")(0.210),
        "20%");
    expect(
        (ScalePow.dynamic()..domain = [0.19, 0.21]).tickFormat(10, "p")(0.201),
        "20.1%");
  });

  test(
      "pow.tickFormat(count, specifier) sets the appropriate prefix precision if not specified",
      () {
    expect(
        (ScalePow.dynamic()..domain = [0, 1e6]).tickFormat(10, r"$s")(0.51e6),
        r"$0.5M");
    expect(
        (ScalePow.dynamic()..domain = [0, 1e6]).tickFormat(100, r"$s")(0.501e6),
        r"$0.50M");
  });

  test("pow.copy() returns a copy with changes to the domain are isolated", () {
    final x = ScalePow.dynamic(), y = x.copy();
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

  test("pow.copy() returns a copy with changes to the range are isolated", () {
    final x = ScalePow.number(), y = x.copy();
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
      "pow.copy() returns a copy with changes to the interpolator are isolated",
      () {
    final x = ScalePow.dynamic()..range = ["red", "blue"],
        y = x.copy(),
        i0 = x.interpolate;
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

  test("pow.copy() returns a copy with changes to clamping are isolated", () {
    final x = ScalePow.dynamic()..clamp = true, y = x.copy();
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
      "(pow()..clamp = true).invert(x) cannot return a value outside the domain",
      () {
    final x = ScalePow.number()
      ..exponent = 0.5
      ..domain = [1, 20]
      ..clamp = true;
    expect(x.invert(0), 1);
    expect(x.invert(1), closeTo(20, 1e-9));
  });

  test("scaleSqrt() is an alias for pow().exponent(0.5)", () {
    final s = ScalePow<num>.sqrt(range: [0, 1], interpolate: interpolateNumber);
    expect(s.exponent, 0.5);
    expect(s(0.5), closeTo(sqrt1_2, 1e-6));
    expect(s.invert(sqrt1_2), closeTo(0.5, 1e-6));
  });
}
