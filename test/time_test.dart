import 'package:d4_interpolate/d4_interpolate.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:d4_time/d4_time.dart';
import 'package:test/test.dart';

import 'date.dart';

void main() {
  test("time.nice() is an alias for time.nice(10)", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 17), local(2009, 0, 1, 23, 42)];
    expect((x..nice()).domain, [local(2009, 0, 1), local(2009, 0, 2)]);
  });

  test("time.nice() can nice sub-second domains", () {
    final x = ScaleTime.dynamic()
      ..domain = [
        local(2013, 0, 1, 12, 0, 0, 0),
        local(2013, 0, 1, 12, 0, 0, 128)
      ];
    expect((x..nice()).domain,
        [local(2013, 0, 1, 12, 0, 0, 0), local(2013, 0, 1, 12, 0, 0, 130)]);
  });

  test("time.nice() can nice multi-year domains", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2001, 0, 1), local(2138, 0, 1)];
    expect((x..nice()).domain, [local(2000, 0, 1), local(2140, 0, 1)]);
  });

  test("time.nice() can nice empty domains", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 12), local(2009, 0, 1, 0, 12)];
    expect((x..nice()).domain,
        [local(2009, 0, 1, 0, 12), local(2009, 0, 1, 0, 12)]);
  });

  test("time.nice(count) nices using the specified tick count", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 17), local(2009, 0, 1, 23, 42)];
    expect((x..nice(100)).domain,
        [local(2009, 0, 1, 0, 15), local(2009, 0, 1, 23, 45)]);
    expect((x..nice(10)).domain, [local(2009, 0, 1), local(2009, 0, 2)]);
  });

  test("time.nice(interval) nices using the specified time interval", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 12), local(2009, 0, 1, 23, 48)];
    expect((x..nice(timeDay)).domain, [local(2009, 0, 1), local(2009, 0, 2)]);
    expect(
        (x..nice(timeWeek)).domain, [local(2008, 11, 28), local(2009, 0, 4)]);
    expect(
        (x..nice(timeMonth)).domain, [local(2008, 11, 1), local(2009, 1, 1)]);
    expect((x..nice(timeYear)).domain, [local(2008, 0, 1), local(2010, 0, 1)]);
  });

  test("time.nice(interval) can nice empty domains", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 12), local(2009, 0, 1, 0, 12)];
    expect((x..nice(timeDay)).domain, [local(2009, 0, 1), local(2009, 0, 2)]);
  });

  test(
      "time.nice(interval) can nice a polylinear domain, only affecting its extent",
      () {
    final x = ScaleTime.dynamic()
      ..domain = [
        local(2009, 0, 1, 0, 12),
        local(2009, 0, 1, 23, 48),
        local(2009, 0, 2, 23, 48)
      ]
      ..nice(timeDay);
    expect(x.domain,
        [local(2009, 0, 1), local(2009, 0, 1, 23, 48), local(2009, 0, 3)]);
  });

  /// modified due to https://github.com/d3/d3-time/pull/66
  test(
      "time.nice(interval.every(step)) nices using the specified time interval and step",
      () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2009, 0, 1, 0, 12), local(2009, 0, 1, 23, 48)];
    expect((x..nice(timeDay.every(3))).domain,
        [local(2008, 11, 31), local(2009, 0, 3)]);
    expect((x..nice(timeWeek.every(2))).domain,
        [local(2008, 11, 21), local(2009, 0, 4)]);
    expect((x..nice(timeMonth.every(3))).domain,
        [local(2008, 9, 1), local(2009, 3, 1)]);
    expect((x..nice(timeYear.every(10))).domain,
        [local(2000, 0, 1), local(2010, 0, 1)]);
  });

  test("time.copy() isolates changes to the domain", () {
    final x = ScaleTime.dynamic()
          ..domain = [local(2009, 0, 1), local(2010, 0, 1)],
        y = x.copy();
    x.domain = [local(2010, 0, 1), local(2011, 0, 1)];
    expect(y.domain, [local(2009, 0, 1), local(2010, 0, 1)]);
    expect(x(local(2010, 0, 1)), 0);
    expect(y(local(2010, 0, 1)), 1);
    y.domain = [local(2011, 0, 1), local(2012, 0, 1)];
    expect(x(local(2011, 0, 1)), 1);
    expect(y(local(2011, 0, 1)), 0);
    expect(x.domain, [local(2010, 0, 1), local(2011, 0, 1)]);
    expect(y.domain, [local(2011, 0, 1), local(2012, 0, 1)]);
  });

  test("time.copy() isolates changes to the range", () {
    final x = ScaleTime.number()
          ..domain = [local(2009, 0, 1), local(2010, 0, 1)],
        y = x.copy();
    x.range = [1, 2];
    expect(x.invert(1), local(2009, 0, 1));
    expect(y.invert(1), local(2010, 0, 1));
    expect(y.range, [0, 1]);
    y.range = [2, 3];
    expect(x.invert(2), local(2010, 0, 1));
    expect(y.invert(2), local(2009, 0, 1));
    expect(x.range, [1, 2]);
    expect(y.range, [2, 3]);
  });

  test("time.copy() isolates changes to the interpolator", () {
    final x = ScaleTime.dynamic()
          ..domain = [local(2009, 0, 1), local(2010, 0, 1)]
          ..range = ["red", "blue"],
        i = x.interpolate,
        y = x.copy();
    x.interpolate = interpolateHsl;
    expect(x(local(2009, 6, 1)), "rgb(255, 0, 253)");
    expect(y(local(2009, 6, 1)), "rgb(129, 0, 126)");
    expect(y.interpolate, i);
  });

  test("time.copy() isolates changes to clamping", () {
    final x = ScaleTime.dynamic()
          ..domain = [local(2009, 0, 1), local(2010, 0, 1)]
          ..clamp = true,
        y = x.copy();
    x.clamp = false;
    expect(x(local(2011, 0, 1)), 2);
    expect(y(local(2011, 0, 1)), 1);
    expect(y.clamp, true);
    y.clamp = false;
    expect(x(local(2011, 0, 1)), 2);
    expect(y(local(2011, 0, 1)), 2);
    expect(x.clamp, false);
  });

  test(
      "time.clamp(true).invert(value) never returns a value outside the domain",
      () {
    final x = ScaleTime.number()..clamp = true;
    expect(x.invert(0), isA<DateTime>());
    //expect(x.invert(0), x.invert(0)); // returns a distinct copy
    expect(x.invert(-1).millisecondsSinceEpoch,
        x.domain[0].millisecondsSinceEpoch);
    expect(
        x.invert(0).millisecondsSinceEpoch, x.domain[0].millisecondsSinceEpoch);
    expect(
        x.invert(1).millisecondsSinceEpoch, x.domain[1].millisecondsSinceEpoch);
    expect(
        x.invert(2).millisecondsSinceEpoch, x.domain[1].millisecondsSinceEpoch);
  });

  test("time.ticks(interval) observes the specified tick interval", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 1, 0), local(2011, 0, 1, 12, 4, 4)];
    expect(x.ticks(timeMinute), [
      local(2011, 0, 1, 12, 1),
      local(2011, 0, 1, 12, 2),
      local(2011, 0, 1, 12, 3),
      local(2011, 0, 1, 12, 4)
    ]);
  });

  test(
      "time.ticks(interval.every(step)) observes the specified tick interval and step",
      () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 33, 4)];
    expect(x.ticks(timeMinute.every(10)), [
      local(2011, 0, 1, 12, 0),
      local(2011, 0, 1, 12, 10),
      local(2011, 0, 1, 12, 20),
      local(2011, 0, 1, 12, 30)
    ]);
  });

  test("time.ticks(count) can generate sub-second ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 0, 1)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 0, 0, 0),
      local(2011, 0, 1, 12, 0, 0, 200),
      local(2011, 0, 1, 12, 0, 0, 400),
      local(2011, 0, 1, 12, 0, 0, 600),
      local(2011, 0, 1, 12, 0, 0, 800),
      local(2011, 0, 1, 12, 0, 1, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-second ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 0, 4)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 0, 0),
      local(2011, 0, 1, 12, 0, 1),
      local(2011, 0, 1, 12, 0, 2),
      local(2011, 0, 1, 12, 0, 3),
      local(2011, 0, 1, 12, 0, 4)
    ]);
  });

  test("time.ticks(count) can generate 5-second ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 0, 20)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 0, 0),
      local(2011, 0, 1, 12, 0, 5),
      local(2011, 0, 1, 12, 0, 10),
      local(2011, 0, 1, 12, 0, 15),
      local(2011, 0, 1, 12, 0, 20)
    ]);
  });

  test("time.ticks(count) can generate 15-second ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 0, 50)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 0, 0),
      local(2011, 0, 1, 12, 0, 15),
      local(2011, 0, 1, 12, 0, 30),
      local(2011, 0, 1, 12, 0, 45)
    ]);
  });

  test("time.ticks(count) can generate 30-second ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 0), local(2011, 0, 1, 12, 1, 50)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 0, 0),
      local(2011, 0, 1, 12, 0, 30),
      local(2011, 0, 1, 12, 1, 0),
      local(2011, 0, 1, 12, 1, 30)
    ]);
  });

  test("time.ticks(count) can generate 1-minute ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 0, 27), local(2011, 0, 1, 12, 4, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 1),
      local(2011, 0, 1, 12, 2),
      local(2011, 0, 1, 12, 3),
      local(2011, 0, 1, 12, 4)
    ]);
  });

  test("time.ticks(count) can generate 5-minute ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 3, 27), local(2011, 0, 1, 12, 21, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 5),
      local(2011, 0, 1, 12, 10),
      local(2011, 0, 1, 12, 15),
      local(2011, 0, 1, 12, 20)
    ]);
  });

  test("time.ticks(count) can generate 15-minute ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 8, 27), local(2011, 0, 1, 13, 4, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 15),
      local(2011, 0, 1, 12, 30),
      local(2011, 0, 1, 12, 45),
      local(2011, 0, 1, 13, 0)
    ]);
  });

  test("time.ticks(count) can generate 30-minute ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 28, 27), local(2011, 0, 1, 14, 4, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 12, 30),
      local(2011, 0, 1, 13, 0),
      local(2011, 0, 1, 13, 30),
      local(2011, 0, 1, 14, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-hour ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 12, 28, 27), local(2011, 0, 1, 16, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 13, 0),
      local(2011, 0, 1, 14, 0),
      local(2011, 0, 1, 15, 0),
      local(2011, 0, 1, 16, 0)
    ]);
  });

  test("time.ticks(count) can generate 3-hour ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 14, 28, 27), local(2011, 0, 2, 1, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 15, 0),
      local(2011, 0, 1, 18, 0),
      local(2011, 0, 1, 21, 0),
      local(2011, 0, 2, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate 6-hour ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 16, 28, 27), local(2011, 0, 2, 14, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 18, 0),
      local(2011, 0, 2, 0, 0),
      local(2011, 0, 2, 6, 0),
      local(2011, 0, 2, 12, 0)
    ]);
  });

  test("time.ticks(count) can generate 12-hour ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 16, 28, 27), local(2011, 0, 3, 21, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 2, 0, 0),
      local(2011, 0, 2, 12, 0),
      local(2011, 0, 3, 0, 0),
      local(2011, 0, 3, 12, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-day ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 1, 16, 28, 27), local(2011, 0, 5, 21, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 2, 0, 0),
      local(2011, 0, 3, 0, 0),
      local(2011, 0, 4, 0, 0),
      local(2011, 0, 5, 0, 0)
    ]);
  });

  /// modified due to https://github.com/d3/d3-time/pull/66
  test("time.ticks(count) can generate 2-day ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 2, 16, 28, 27), local(2011, 0, 9, 21, 34, 12)];
    expect(x.ticks(4), [
      local(2011, 0, 4, 0, 0),
      local(2011, 0, 6, 0, 0),
      local(2011, 0, 8, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-week ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [
        local(2011, 0, 1, 16, 28, 27),
        local(2011, 0, 23, 21, 34, 12)
      ];
    expect(x.ticks(4), [
      local(2011, 0, 2, 0, 0),
      local(2011, 0, 9, 0, 0),
      local(2011, 0, 16, 0, 0),
      local(2011, 0, 23, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-month ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2011, 0, 18), local(2011, 4, 2)];
    expect(x.ticks(4), [
      local(2011, 1, 1, 0, 0),
      local(2011, 2, 1, 0, 0),
      local(2011, 3, 1, 0, 0),
      local(2011, 4, 1, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate 3-month ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2010, 11, 18), local(2011, 10, 2)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 0, 0),
      local(2011, 3, 1, 0, 0),
      local(2011, 6, 1, 0, 0),
      local(2011, 9, 1, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate 1-year ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2010, 11, 18), local(2014, 2, 2)];
    expect(x.ticks(4), [
      local(2011, 0, 1, 0, 0),
      local(2012, 0, 1, 0, 0),
      local(2013, 0, 1, 0, 0),
      local(2014, 0, 1, 0, 0)
    ]);
  });

  test("time.ticks(count) can generate multi-year ticks", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(0, 11, 18), local(2014, 2, 2)];
    expect(x.ticks(6), [
      local(500, 0, 1, 0, 0),
      local(1000, 0, 1, 0, 0),
      local(1500, 0, 1, 0, 0),
      local(2000, 0, 1, 0, 0)
    ]);
  });

  test("time.ticks(count) returns one tick for an empty domain", () {
    final x = ScaleTime.dynamic()
      ..domain = [local(2014, 2, 2), local(2014, 2, 2)];
    expect(x.ticks(6), [local(2014, 2, 2)]);
  });

  test("time.ticks() returns descending ticks for a descending domain", () {
    final x = ScaleTime.dynamic();
    expect((x..domain = [local(2014, 2, 2), local(2010, 11, 18)]).ticks(4), [
      local(2014, 0, 1, 0, 0),
      local(2013, 0, 1, 0, 0),
      local(2012, 0, 1, 0, 0),
      local(2011, 0, 1, 0, 0)
    ]);
    expect((x..domain = [local(2011, 10, 2), local(2010, 11, 18)]).ticks(4), [
      local(2011, 9, 1, 0, 0),
      local(2011, 6, 1, 0, 0),
      local(2011, 3, 1, 0, 0),
      local(2011, 0, 1, 0, 0)
    ]);
  });

  test("time.tickFormat()(date) formats year on New Year's", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 0, 1)), "2011");
    expect(f(local(2012, 0, 1)), "2012");
    expect(f(local(2013, 0, 1)), "2013");
  });

  test("time.tickFormat()(date) formats month on the 1st of each month", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 1)), "February");
    expect(f(local(2011, 2, 1)), "March");
    expect(f(local(2011, 3, 1)), "April");
  });

  test("time.tickFormat()(date) formats week on Sunday midnight", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 6)), "Feb 06");
    expect(f(local(2011, 1, 13)), "Feb 13");
    expect(f(local(2011, 1, 20)), "Feb 20");
  });

  test("time.tickFormat()(date) formats date on midnight", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 2)), "Wed 02");
    expect(f(local(2011, 1, 3)), "Thu 03");
    expect(f(local(2011, 1, 4)), "Fri 04");
  });

  test("time.tickFormat()(date) formats hour on minute zero", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 2, 11)), "11 AM");
    expect(f(local(2011, 1, 2, 12)), "12 PM");
    expect(f(local(2011, 1, 2, 13)), "01 PM");
  });

  test("time.tickFormat()(date) formats minute on second zero", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 2, 11, 59)), "11:59");
    expect(f(local(2011, 1, 2, 12, 1)), "12:01");
    expect(f(local(2011, 1, 2, 12, 2)), "12:02");
  });

  test("time.tickFormat()(date) otherwise, formats second", () {
    final f = ScaleTime.dynamic().tickFormat();
    expect(f(local(2011, 1, 2, 12, 1, 9)), ":09");
    expect(f(local(2011, 1, 2, 12, 1, 10)), ":10");
    expect(f(local(2011, 1, 2, 12, 1, 11)), ":11");
  });

  test(
      "time.tickFormat(count, specifier) returns a time format for the specified specifier",
      () {
    final f = ScaleTime.dynamic().tickFormat(10, "%c");
    expect(f(local(2011, 1, 2, 12)), "2/2/2011, 12:00:00 PM");
  });
}
