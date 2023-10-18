import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleBand() has the expected defaults", () {
    final s = ScaleBand();
    expect(s.domain, []);
    expect(s.range, [0, 1]);
    expect(s.bandwidth, 1);
    expect(s.step, 1);
    expect(s.round, false);
    expect(s.paddingInner, 0);
    expect(s.paddingOuter, 0);
    expect(s.align, 0.5);
  });

  test("band(value) computes discrete bands in a continuous range", () {
    final s = ScaleBand<String>(range: [0, 960]);
    expect(s("foo"), null);
    s.domain = ["foo", "bar"];
    expect(s("foo"), 0);
    expect(s("bar"), 480);
    s
      ..domain = ["a", "b", "c"]
      ..range = [0, 120];
    expect(s.domain.map(s), [0, 40, 80]);
    expect(s.bandwidth, 40);
    s.padding = 0.2;
    expect(s.domain.map(s), [7.5, 45, 82.5]);
    expect(s.bandwidth, 30);
  });

  test("band(value) returns undefined for values outside the domain", () {
    final s = ScaleBand(domain: ["a", "b", "c"], range: [0, 1]);
    expect(s("d"), null);
    expect(s("e"), null);
    expect(s("f"), null);
  });

  test("band(value) does not implicitly add values to the domain", () {
    final s = ScaleBand(domain: ["a", "b", "c"], range: [0, 1]);
    s("d");
    s("e");
    expect(s.domain, ["a", "b", "c"]);
  });

  test("band.step() returns the distance between the starts of adjacent bands",
      () {
    final s = ScaleBand(range: [0, 960]);
    expect((s..domain = ["foo"]).step, 960);
    expect((s..domain = ["foo", "bar"]).step, 480);
    expect((s..domain = ["foo", "bar", "baz"]).step, 320);
    s.padding = 0.5;
    expect((s..domain = ["foo"]).step, 640);
    expect((s..domain = ["foo", "bar"]).step, 384);
  });

  test("band.bandwidth() returns the width of the band", () {
    final s = ScaleBand(range: [0, 960]);
    expect((s..domain = []).bandwidth, 960);
    expect((s..domain = ["foo"]).bandwidth, 960);
    expect((s..domain = ["foo", "bar"]).bandwidth, 480);
    expect((s..domain = ["foo", "bar", "baz"]).bandwidth, 320);
    s.padding = 0.5;
    expect((s..domain = []).bandwidth, 480);
    expect((s..domain = ["foo"]).bandwidth, 320);
    expect((s..domain = ["foo", "bar"]).bandwidth, 192);
  });

  test("band.domain([]) computes reasonable band and step values", () {
    final s = ScaleBand(range: [0, 960])..domain = [];
    expect(s.step, 960);
    expect(s.bandwidth, 960);
    s.padding = 0.5;
    expect(s.step, 960);
    expect(s.bandwidth, 480);
    s.padding = 1;
    expect(s.step, 960);
    expect(s.bandwidth, 0);
  });

  test(
      "band.domain([value]) computes a reasonable singleton band, even with padding",
      () {
    final s = ScaleBand(range: [0, 960])..domain = ["foo"];
    expect(s("foo"), 0);
    expect(s.step, 960);
    expect(s.bandwidth, 960);
    s.padding = 0.5;
    expect(s("foo"), 320);
    expect(s.step, 640);
    expect(s.bandwidth, 320);
    s.padding = 1;
    expect(s("foo"), 480);
    expect(s.step, 480);
    expect(s.bandwidth, 0);
  });

  test("band.domain(values) recomputes the bands", () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..rangeRound([0, 100]);
    expect(s.domain.map(s), [1, 34, 67]);
    expect(s.bandwidth, 33);
    s.domain = ["a", "b", "c", "d"];
    expect(s.domain.map(s), [0, 25, 50, 75]);
    expect(s.bandwidth, 25);
  });

  test("band.domain(values) makes a copy of the specified domain values", () {
    final domain = ["red", "green"];
    final s = ScaleBand()..domain = domain;
    domain.add("blue");
    expect(s.domain, ["red", "green"]);
  });

  test("band.domain() returns a copy of the domain", () {
    final s = ScaleBand()..domain = ["red", "green"];
    final domain = s.domain;
    expect(domain, ["red", "green"]);
    domain.add("blue");
    expect(s.domain, ["red", "green"]);
  });

  test("band.range(values) can be descending", () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..range = [120, 0];
    expect(s.domain.map(s), [80, 40, 0]);
    expect(s.bandwidth, 40);
    s.padding = 0.2;
    expect(s.domain.map(s), [82.5, 45, 7.5]);
    expect(s.bandwidth, 30);
  });

  test("band.range(values) makes a copy of the specified range values", () {
    final range = [1, 2];
    final s = ScaleBand()..range = range;
    range.add(3);
    expect(s.range, [1, 2]);
  });

  test("band.range() returns a copy of the range", () {
    final s = ScaleBand()..range = [1, 2];
    final range = s.range;
    expect(range, [1, 2]);
    range.add(3);
    expect(s.range, [1, 2]);
  });

  test("band.paddingInner(p) specifies the inner padding p", () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..range = [120, 0]
      ..paddingInner = 0.1
      ..round = true;
    expect(s.domain.map(s), [83, 42, 1]);
    expect(s.bandwidth, 37);
    s.paddingInner = 0.2;
    expect(s.domain.map(s), [85, 43, 1]);
    expect(s.bandwidth, 34);
  });

  test("band.paddingOuter(p) specifies the outer padding p", () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..range = [120, 0]
      ..paddingInner = 0.2
      ..paddingOuter = 0.1;
    expect(s.domain.map(s), [84, 44, 4]);
    expect(s.bandwidth, 32);
    s.paddingOuter = 1;
    expect(s.domain.map(s), [75, 50, 25]);
    expect(s.bandwidth, 20);
  });

  test("band.rangeRound(values) is an alias for band.range(values).round(true)",
      () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..rangeRound([0, 100]);
    expect(s.range, [0, 100]);
    expect(s.round, true);
  });

  test("band.round(true) computes discrete rounded bands in a continuous range",
      () {
    final s = ScaleBand()
      ..domain = ["a", "b", "c"]
      ..range = [0, 100]
      ..round = true;
    expect(s.domain.map(s), [1, 34, 67]);
    expect(s.bandwidth, 33);
    s.padding = 0.2;
    expect(s.domain.map(s), [7, 38, 69]);
    expect(s.bandwidth, 25);
  });

  test("band.copy() copies all fields", () {
    final s1 = ScaleBand()
      ..domain = ["red", "green"]
      ..range = [1, 2]
      ..round = true
      ..paddingInner = 0.1
      ..paddingOuter = 0.2;
    final s2 = s1.copy();
    expect(s2.domain, s1.domain);
    expect(s2.range, s1.range);
    expect(s2.round, s1.round);
    expect(s2.paddingInner, s1.paddingInner);
    expect(s2.paddingOuter, s1.paddingOuter);
  });

  test("band.copy() isolates changes to the domain", () {
    final s1 = ScaleBand()
      ..domain = ["foo", "bar"]
      ..range = [0, 2];
    final s2 = s1.copy();
    s1.domain = ["red", "blue"];
    expect(s2.domain, ["foo", "bar"]);
    expect(s1.domain.map(s1), [0, 1]);
    expect(s2.domain.map(s2), [0, 1]);
    s2.domain = ["red", "blue"];
    expect(s1.domain, ["red", "blue"]);
    expect(s1.domain.map(s1), [0, 1]);
    expect(s2.domain.map(s2), [0, 1]);
  });

  test("band.copy() isolates changes to the range", () {
    final s1 = ScaleBand()
      ..domain = ["foo", "bar"]
      ..range = [0, 2];
    final s2 = s1.copy();
    s1.range = [3, 5];
    expect(s2.range, [0, 2]);
    expect(s1.domain.map(s1), [3, 4]);
    expect(s2.domain.map(s2), [0, 1]);
    s2.range = [5, 7];
    expect(s1.range, [3, 5]);
    expect(s1.domain.map(s1), [3, 4]);
    expect(s2.domain.map(s2), [5, 6]);
  });
}
