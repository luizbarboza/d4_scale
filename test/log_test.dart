import 'dart:math';

import 'package:d4_color/d4_color.dart';
import 'package:d4_format/d4_format.dart';
import 'package:d4_interpolate/d4_interpolate.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleLog.dynamic() has the expected defaults", () {
    var x = ScaleLog.dynamic();
    expect(x.domain, [1, 10]);
    expect(x.range, [0, 1]);
    expect(x.clamp, false);
    expect(x.base, 10);
    expect(x.interpolate, interpolate);
    expect(
        x.interpolate({
          "array": ["red"]
        }, {
          "array": ["blue"]
        })(0.5),
        {
          "array": ["rgb(128, 0, 128)"]
        });
    x = ScaleLog.number();
    expect(x(5), closeTo(0.69897, 1e-6));
    expect((x as ScaleLog<num>).invert(0.69897), closeTo(5, 1e-6));
    expect(x(3.162278), closeTo(0.5, 1e-6));
    expect(x.invert(0.5), closeTo(3.162278, 1e-6));
  });

  test("log.domain(…) can take negative values", () {
    final x = ScaleLog.dynamic()..domain = [-100, -1];
    expect(x.ticks().map(x.tickFormat(double.infinity)), [
      "−100",
      "−90",
      "−80",
      "−70",
      "−60",
      "−50",
      "−40",
      "−30",
      "−20",
      "−10",
      "−9",
      "−8",
      "−7",
      "−6",
      "−5",
      "−4",
      "−3",
      "−2",
      "−1"
    ]);
    expect(x(-50), closeTo(0.150515, 1e-6));
  });

  test("log.domain(…).range(…) can take more than two values", () {
    final x = ScaleLog.dynamic()
      ..domain = [0.1, 1, 100]
      ..range = ["red", "white", "green"];
    expect(x(0.5), "rgb(255, 178, 178)");
    expect(x(50), "rgb(38, 147, 38)");
    expect(x(75), "rgb(16, 136, 16)");
  });

  test(
      "log.domain(…) preserves specified domain exactly, with no floating point error",
      () {
    final x = ScaleLog.dynamic()..domain = [0.1, 1000];
    expect(x.domain, [0.1, 1000]);
  });

  test("log.ticks(…) returns exact ticks, with no floating point error", () {
    expect((ScaleLog.dynamic()..domain = [0.15, 0.68]).ticks(),
        [0.2, 0.3, 0.4, 0.5, 0.6]);
    expect((ScaleLog.dynamic()..domain = [0.68, 0.15]).ticks(),
        [0.6, 0.5, 0.4, 0.3, 0.2]);
    expect((ScaleLog.dynamic()..domain = [-0.15, -0.68]).ticks(),
        [-0.2, -0.3, -0.4, -0.5, -0.6]);
    expect((ScaleLog.dynamic()..domain = [-0.68, -0.15]).ticks(),
        [-0.6, -0.5, -0.4, -0.3, -0.2]);
  });

  test("log.range(…) does not coerce values to numbers", () {
    final x = ScaleLog.dynamic()..range = ["0", "2"];
    expect(x.range[0], isA<String>());
    expect(x.range[1], isA<String>());
  });

  test("log.range(…) can take colors", () {
    final x = ScaleLog.dynamic()..range = ["red", "blue"];
    expect(x(5), "rgb(77, 0, 178)");
    x.range = ["#ff0000", "#0000ff"];
    expect(x(5), "rgb(77, 0, 178)");
    x.range = ["#f00", "#00f"];
    expect(x(5), "rgb(77, 0, 178)");
    x.range = [Rgb(255, 0, 0), Hsl(240, 1, 0.5)];
    expect(x(5), "rgb(77, 0, 178)");
    x.range = ["hsl(0,100%,50%)", "hsl(240,100%,50%)"];
    expect(x(5), "rgb(77, 0, 178)");
  });

  test("log.range(…) can take arrays or objects", () {
    final x = ScaleLog.dynamic()
      ..range = [
        {"color": "red"},
        {"color": "blue"}
      ];
    expect(x(5), {"color": "rgb(77, 0, 178)"});
    x.range = [
      ["red"],
      ["blue"]
    ];
    expect(x(5), ["rgb(77, 0, 178)"]);
  });

  test("log.interpolate(f) sets the interpolator", () {
    final x = ScaleLog.dynamic()..range = ["red", "blue"];
    expect(x.interpolate, interpolate);
    expect(x(5), "rgb(77, 0, 178)");
    x.interpolate = interpolateHsl;
    expect(x(5), "rgb(154, 0, 255)");
  });

  test("log(x) does not clamp by default", () {
    final x = ScaleLog.dynamic();
    expect(x.clamp, false);
    expect(x(0.5), closeTo(-0.3010299, 1e-6));
    expect(x(15), closeTo(1.1760913, 1e-6));
  });

  test("log.clamp(true)(x) clamps to the domain", () {
    final x = ScaleLog.dynamic()..clamp = true;
    expect(x(-1), closeTo(0, 1e-6));
    expect(x(5), closeTo(0.69897, 1e-6));
    expect(x(15), closeTo(1, 1e-6));
    x.domain = [10, 1];
    expect(x(-1), closeTo(1, 1e-6));
    expect(x(5), closeTo(0.30103, 1e-6));
    expect(x(15), closeTo(0, 1e-6));
  });

  test("log.clamp(true).invert(y) clamps to the range", () {
    final x = ScaleLog.number()..clamp = true;
    expect(x.invert(-0.1), closeTo(1, 1e-6));
    expect(x.invert(0.69897), closeTo(5, 1e-6));
    expect(x.invert(1.5), closeTo(10, 1e-6));
    x.domain = [10, 1];
    expect(x.invert(-0.1), closeTo(10, 1e-6));
    expect(x.invert(0.30103), closeTo(5, 1e-6));
    expect(x.invert(1.5), closeTo(1, 1e-6));
  });

  test("log(x) maps a number x to a number y", () {
    final x = ScaleLog.dynamic()..domain = [1, 2];
    expect(x(0.5), closeTo(-1.0000000, 1e-6));
    expect(x(1.0), closeTo(0.0000000, 1e-6));
    expect(x(1.5), closeTo(0.5849625, 1e-6));
    expect(x(2.0), closeTo(1.0000000, 1e-6));
    expect(x(2.5), closeTo(1.3219281, 1e-6));
  });

  test("log.invert(y) maps a number y to a number x", () {
    final x = ScaleLog.number()..domain = [1, 2];
    expect(x.invert(-1.0000000), closeTo(0.5, 1e-6));
    expect(x.invert(0.0000000), closeTo(1.0, 1e-6));
    expect(x.invert(0.5849625), closeTo(1.5, 1e-6));
    expect(x.invert(1.0000000), closeTo(2.0, 1e-6));
    expect(x.invert(1.3219281), closeTo(2.5, 1e-6));
  });

  test("log.base(b) sets the log base, changing the ticks", () {
    final x = ScaleLog.dynamic()..domain = [1, 32];
    expect((x..base = 2).ticks().map(x.tickFormat()),
        ["1", "2", "4", "8", "16", "32"]);
    expect((x..base = e).ticks().map(x.tickFormat()),
        ["1", "2.71828182846", "7.38905609893", "20.0855369232"]);
  });

  test("log.nice() nices the domain, extending it to powers of ten", () {
    final x = ScaleLog.dynamic()
      ..domain = [1.1, 10.9]
      ..nice();
    expect(x.domain, [1, 100]);
    (x..domain = [10.9, 1.1]).nice();
    expect(x.domain, [100, 1]);
    (x..domain = [0.7, 11.001]).nice();
    expect(x.domain, [0.1, 100]);
    (x..domain = [123.1, 6.7]).nice();
    expect(x.domain, [1000, 1]);
    (x..domain = [0.01, 0.49]).nice();
    expect(x.domain, [0.01, 1]);
    (x..domain = [1.5, 50]).nice();
    expect(x.domain, [1, 100]);
    expect(x(1), closeTo(0, 1e-6));
    expect(x(100), closeTo(1, 1e-6));
  });

  test("log.nice() works on degenerate domains", () {
    final x = ScaleLog.dynamic()
      ..domain = [0, 0]
      ..nice();
    expect(x.domain, [0, 0]);
    (x..domain = [0.5, 0.5]).nice();
    expect(x.domain, [0.1, 1]);
  });

  test("log.nice() on a polylog domain only affects the extent", () {
    final x = ScaleLog.dynamic()
      ..domain = [1.1, 1.5, 10.9]
      ..nice();
    expect(x.domain, [1, 1.5, 100]);
    (x..domain = [-123.1, -1.5, -0.5]).nice();
    expect(x.domain, [-1000, -1.5, -0.1]);
  });

  test("log.copy() isolates changes to the domain", () {
    final x = ScaleLog.dynamic(), y = x.copy();
    x.domain = [10, 100];
    expect(y.domain, [1, 10]);
    expect(x(10), closeTo(0, 1e-6));
    expect(y(1), closeTo(0, 1e-6));
    y.domain = [100, 1000];
    expect(x(100), closeTo(1, 1e-6));
    expect(y(100), closeTo(0, 1e-6));
    expect(x.domain, [10, 100]);
    expect(y.domain, [100, 1000]);
  });

  test("log.copy() isolates changes to the domain via nice", () {
    final x = ScaleLog.number()..domain = [1.5, 50], y = x.copy()..nice();
    expect(x.domain, [1.5, 50]);
    expect(x(1.5), closeTo(0, 1e-6));
    expect(x(50), closeTo(1, 1e-6));
    expect(x.invert(0), closeTo(1.5, 1e-6));
    expect(x.invert(1), closeTo(50, 1e-6));
    expect(y.domain, [1, 100]);
    expect(y(1), closeTo(0, 1e-6));
    expect(y(100), closeTo(1, 1e-6));
    expect(y.invert(0), closeTo(1, 1e-6));
    expect(y.invert(1), closeTo(100, 1e-6));
  });

  test("log.copy() isolates changes to the range", () {
    final x = ScaleLog.number(), y = x.copy();
    x.range = [1, 2];
    expect(x.invert(1), closeTo(1, 1e-6));
    expect(y.invert(1), closeTo(10, 1e-6));
    expect(y.range, [0, 1]);
    y.range = [2, 3];
    expect(x.invert(2), closeTo(10, 1e-6));
    expect(y.invert(2), closeTo(1, 1e-6));
    expect(x.range, [1, 2]);
    expect(y.range, [2, 3]);
  });

  test("log.copy() isolates changes to the interpolator", () {
    final x = ScaleLog.dynamic()..range = ["red", "blue"], y = x.copy();
    x.interpolate = interpolateHsl;
    expect(x(5), "rgb(154, 0, 255)");
    expect(y(5), "rgb(77, 0, 178)");
    expect(y.interpolate, interpolate);
  });

  test("log.copy() isolates changes to clamping", () {
    final x = ScaleLog.dynamic()..clamp = true, y = x.copy();
    x.clamp = false;
    expect(x(0.5), closeTo(-0.30103, 1e-6));
    expect(y(0.5), closeTo(0, 1e-6));
    expect(y.clamp, true);
    y.clamp = false;
    expect(x(20), closeTo(1.30103, 1e-6));
    expect(y(20), closeTo(1.30103, 1e-6));
    expect(x.clamp, false);
  });

  test("log.ticks() generates the expected power-of-ten for ascending ticks",
      () {
    final s = ScaleLog.dynamic();
    expect((s..domain = [1e-1, 1e1]).ticks().map(round), [
      0.1,
      0.2,
      0.3,
      0.4,
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10
    ]);
    expect((s..domain = [1e-1, 1e0]).ticks().map(round),
        [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]);
    expect((s..domain = [-1e0, -1e-1]).ticks().map(round),
        [-1, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1]);
  });

  test(
      "log.ticks() generates the expected power-of-ten ticks for descending domains",
      () {
    final s = ScaleLog.dynamic();
    expect(
        (s..domain = [-1e-1, -1e1]).ticks().map(round),
        [
          -10,
          -9,
          -8,
          -7,
          -6,
          -5,
          -4,
          -3,
          -2,
          -1,
          -0.9,
          -0.8,
          -0.7,
          -0.6,
          -0.5,
          -0.4,
          -0.3,
          -0.2,
          -0.1
        ].reversed);
    expect((s..domain = [-1e-1, -1e0]).ticks().map(round),
        [-1, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1].reversed);
    expect((s..domain = [1e0, 1e-1]).ticks().map(round),
        [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1].reversed);
  });

  test(
      "log.ticks() generates the expected power-of-ten ticks for small domains",
      () {
    final s = ScaleLog.dynamic();
    expect((s..domain = [1, 5]).ticks(), [1, 2, 3, 4, 5]);
    expect((s..domain = [5, 1]).ticks(), [5, 4, 3, 2, 1]);
    expect((s..domain = [-1, -5]).ticks(), [-1, -2, -3, -4, -5]);
    expect((s..domain = [-5, -1]).ticks(), [-5, -4, -3, -2, -1]);
    expect((s..domain = [286.9252014, 329.4978332]).ticks(1), [300]);
    expect((s..domain = [286.9252014, 329.4978332]).ticks(2), [300]);
    expect((s..domain = [286.9252014, 329.4978332]).ticks(3), [300, 320]);
    expect((s..domain = [286.9252014, 329.4978332]).ticks(4),
        [290, 300, 310, 320]);
    expect((s..domain = [286.9252014, 329.4978332]).ticks(),
        [290, 295, 300, 305, 310, 315, 320, 325]);
  });

  test("log.ticks() generates linear ticks when the domain extent is small",
      () {
    final s = ScaleLog.dynamic();
    expect((s..domain = [41, 42]).ticks(),
        [41, 41.1, 41.2, 41.3, 41.4, 41.5, 41.6, 41.7, 41.8, 41.9, 42]);
    expect((s..domain = [42, 41]).ticks(),
        [42, 41.9, 41.8, 41.7, 41.6, 41.5, 41.4, 41.3, 41.2, 41.1, 41]);
    expect((s..domain = [1600, 1400]).ticks(),
        [1600, 1580, 1560, 1540, 1520, 1500, 1480, 1460, 1440, 1420, 1400]);
  });

  test("log.base(base).ticks() generates the expected power-of-base ticks", () {
    final s = ScaleLog.dynamic()..base = e;
    expect((s..domain = [0.1, 100]).ticks().map(round), [
      0.135335283237,
      0.367879441171,
      1,
      2.718281828459,
      7.389056098931,
      20.085536923188,
      54.598150033144
    ]);
  });

  test("log.tickFormat() is equivalent to log.tickFormat(10)", () {
    final s = ScaleLog.dynamic();
    expect((s..domain = [1e-1, 1e1]).ticks().map(s.tickFormat()), [
      "100m",
      "200m",
      "300m",
      "400m",
      "500m",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "4",
      "5",
      "",
      "",
      "",
      "",
      "10"
    ]);
  });

  test("log.tickFormat(count) returns a filtered \"s\" format", () {
    final s = ScaleLog.dynamic(), t = (s..domain = [1e-1, 1e1]).ticks();
    expect(t.map(s.tickFormat(10)), [
      "100m",
      "200m",
      "300m",
      "400m",
      "500m",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "4",
      "5",
      "",
      "",
      "",
      "",
      "10"
    ]);
    expect(t.map(s.tickFormat(5)), [
      "100m",
      "200m",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "10"
    ]);
    expect(t.map(s.tickFormat(1)), [
      "100m",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "10"
    ]);
    expect(t.map(s.tickFormat(0)), [
      "100m",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "10"
    ]);
  });

  test("log.tickFormat(count, format) returns the specified format, filtered",
      () {
    final s = ScaleLog.dynamic(), t = (s..domain = [1e-1, 1e1]).ticks();
    expect(t.map(s.tickFormat(10, "+")), [
      "+0.1",
      "+0.2",
      "+0.3",
      "+0.4",
      "+0.5",
      "",
      "",
      "",
      "",
      "+1",
      "+2",
      "+3",
      "+4",
      "+5",
      "",
      "",
      "",
      "",
      "+10"
    ]);
  });

  test("log.base(base).tickFormat() returns the \",\" format", () {
    final s = ScaleLog.dynamic()..base = e;
    expect((s..domain = [1e-1, 1e1]).ticks().map(s.tickFormat()), [
      "0.135335283237",
      "0.367879441171",
      "1",
      "2.71828182846",
      "7.38905609893"
    ]);
  });

  test("log.base(base).tickFormat(count) returns a filtered \",\" format", () {
    final s = ScaleLog.dynamic()..base = 16,
        t = (s..domain = [1e-1, 1e1]).ticks();
    expect(t.map(s.tickFormat(10)), [
      "0.125",
      "0.1875",
      "0.25",
      "0.3125",
      "0.375",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "",
      "",
      "",
      ""
    ]);
    expect(t.map(s.tickFormat(5)), [
      "0.125",
      "0.1875",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ]);
    expect(t.map(s.tickFormat(1)), [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ]);
  });

  test("log.ticks() generates log ticks", () {
    final x = ScaleLog.dynamic();
    expect(x.ticks().map(x.tickFormat(double.infinity)),
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]);
    x.domain = [100, 1];
    expect(x.ticks().map(x.tickFormat(double.infinity)), [
      "100",
      "90",
      "80",
      "70",
      "60",
      "50",
      "40",
      "30",
      "20",
      "10",
      "9",
      "8",
      "7",
      "6",
      "5",
      "4",
      "3",
      "2",
      "1"
    ]);
    x.domain = [0.49999, 0.006029505943610648];
    expect(x.ticks().map(x.tickFormat(double.infinity)), [
      "400m",
      "300m",
      "200m",
      "100m",
      "90m",
      "80m",
      "70m",
      "60m",
      "50m",
      "40m",
      "30m",
      "20m",
      "10m",
      "9m",
      "8m",
      "7m"
    ]);
    x.domain = [0.95, 1.05e8];
    expect(x.ticks().map(x.tickFormat(8)).where((t) => t.isNotEmpty),
        ["1", "10", "100", "1k", "10k", "100k", "1M", "10M", "100M"]);
  });

  test("log.tickFormat(count) filters ticks to about count", () {
    final x = ScaleLog.dynamic();
    expect(x.ticks().map(x.tickFormat(5)),
        ["1", "2", "3", "4", "5", "", "", "", "", "10"]);
    x.domain = [100, 1];
    expect(x.ticks().map(x.tickFormat(10)), [
      "100",
      "",
      "",
      "",
      "",
      "50",
      "40",
      "30",
      "20",
      "10",
      "",
      "",
      "",
      "",
      "5",
      "4",
      "3",
      "2",
      "1"
    ]);
  });

  test("log.ticks(count) filters powers-of-ten ticks for huge domains", () {
    final x = ScaleLog.dynamic()..domain = [1e10, 1];
    expect(x.ticks().map(x.tickFormat()), [
      "10G",
      "1G",
      "100M",
      "10M",
      "1M",
      "100k",
      "10k",
      "1k",
      "100",
      "10",
      "1"
    ]);
    x.domain = [1e-29, 1e-1];
    expect(x.ticks().map(x.tickFormat()), [
      "0.0001y",
      "0.01y",
      "1y",
      "100y",
      "10z",
      "1a",
      "100a",
      "10f",
      "1p",
      "100p",
      "10n",
      "1µ",
      "100µ",
      "10m"
    ]);
  });

  test("log.ticks() generates ticks that cover the domain", () {
    final x = ScaleLog.dynamic()..domain = [0.01, 10000];
    expect(x.ticks(20).map(x.tickFormat(20)), [
      "10m",
      "20m",
      "30m",
      "",
      "",
      "",
      "",
      "",
      "",
      "100m",
      "200m",
      "300m",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "",
      "",
      "",
      "",
      "",
      "",
      "10",
      "20",
      "30",
      "",
      "",
      "",
      "",
      "",
      "",
      "100",
      "200",
      "300",
      "",
      "",
      "",
      "",
      "",
      "",
      "1k",
      "2k",
      "3k",
      "",
      "",
      "",
      "",
      "",
      "",
      "10k"
    ]);
  });

  test("log.ticks() generates ticks that cover the niced domain", () {
    final x = ScaleLog.dynamic()
      ..domain = [0.0124123, 1230.4]
      ..nice();
    expect(x.ticks(20).map(x.tickFormat(20)), [
      "10m",
      "20m",
      "30m",
      "",
      "",
      "",
      "",
      "",
      "",
      "100m",
      "200m",
      "300m",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "2",
      "3",
      "",
      "",
      "",
      "",
      "",
      "",
      "10",
      "20",
      "30",
      "",
      "",
      "",
      "",
      "",
      "",
      "100",
      "200",
      "300",
      "",
      "",
      "",
      "",
      "",
      "",
      "1k",
      "2k",
      "3k",
      "",
      "",
      "",
      "",
      "",
      "",
      "10k"
    ]);
  });

  test("log.tickFormat(count, format) returns a filtered format", () {
    final x = ScaleLog.dynamic()..domain = [1000.1, 1];
    expect(x.ticks().map(x.tickFormat(10, format("+,d"))), [
      "+1,000",
      "",
      "",
      "",
      "",
      "",
      "",
      "+300",
      "+200",
      "+100",
      "",
      "",
      "",
      "",
      "",
      "",
      "+30",
      "+20",
      "+10",
      "",
      "",
      "",
      "",
      "",
      "",
      "+3",
      "+2",
      "+1"
    ]);
  });

  test("log.tickFormat(count, specifier) returns a filtered format", () {
    final x = ScaleLog.dynamic()..domain = [1000.1, 1];
    expect(x.ticks().map(x.tickFormat(10, "s")), [
      "1k",
      "",
      "",
      "",
      "",
      "",
      "",
      "300",
      "200",
      "100",
      "",
      "",
      "",
      "",
      "",
      "",
      "30",
      "20",
      "10",
      "",
      "",
      "",
      "",
      "",
      "",
      "3",
      "2",
      "1"
    ]);
  });

  test("log.tickFormat(count, specifier) trims trailing zeroes by default", () {
    final x = ScaleLog.dynamic()..domain = [100.1, 0.02];
    expect(x.ticks().map(x.tickFormat(10, "f")), [
      "100",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "20",
      "10",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "2",
      "1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "0.2",
      "0.1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "0.02"
    ]);
  });

  test(
      "log.tickFormat(count, specifier) with base two trims trailing zeroes by default",
      () {
    final x = ScaleLog.dynamic()
      ..base = 2
      ..domain = [100.1, 0.02];
    expect(x.ticks().map(x.tickFormat(10, "f")), [
      "64",
      "32",
      "16",
      "8",
      "4",
      "2",
      "1",
      "0.5",
      "0.25",
      "0.125",
      "0.0625",
      "0.03125"
    ]);
  });

  test("log.tickFormat(count, specifier) preserves trailing zeroes if needed",
      () {
    final x = ScaleLog.dynamic()..domain = [100.1, 0.02];
    expect(x.ticks().map(x.tickFormat(10, ".1f")), [
      "100.0",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "20.0",
      "10.0",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "2.0",
      "1.0",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "0.2",
      "0.1",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "0.0"
    ]);
  });

  test("log.ticks() returns the empty array when the domain is degenerate", () {
    final x = ScaleLog.dynamic();
    expect((x..domain = [0, 1]).ticks(), []);
    expect((x..domain = [1, 0]).ticks(), []);
    expect((x..domain = [0, -1]).ticks(), []);
    expect((x..domain = [-1, 0]).ticks(), []);
    expect((x..domain = [-1, 1]).ticks(), []);
    expect((x..domain = [0, 0]).ticks(), []);
  });
}

num round(num x) {
  return (x * 1e12).round() / 1e12;
}
