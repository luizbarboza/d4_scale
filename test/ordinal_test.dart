import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleOrdinal() has the expected defaults", () {
    final s = ScaleOrdinal();
    expect(s.domain, []);
    expect(s.range, []);
    expect(s(0), null);
    expect(s.unknown, null);
    expect(s.domain, [0]);
  });

  test(
      "ordinal(x) maps a unique name x in the domain to the corresponding value y in the range",
      () {
    final s = ScaleOrdinal()
      ..domain = [0, 1]
      ..range = ["foo", "bar"]
      ..implicit = false;
    expect(s(0), "foo");
    expect(s(1), "bar");
    s.range = ["a", "b", "c"];
    expect(s(0), "a");
    expect(s("0"), null);
    expect(s([0]), null);
    expect(s(1), "b");
    expect(s(2), null);
  });

  test(
      "ordinal(x) implicitly extends the domain when a range is explicitly specified",
      () {
    final s = ScaleOrdinal()..range = ["foo", "bar"];
    expect(s.domain, []);
    expect(s(0), "foo");
    expect(s.domain, [0]);
    expect(s(1), "bar");
    expect(s.domain, [0, 1]);
    expect(s(0), "foo");
    expect(s.domain, [0, 1]);
  });

  test("ordinal.domain(x) makes a copy of the domain", () {
    final domain = ["red", "green"];
    final s = ScaleOrdinal()..domain = domain;
    domain.add("blue");
    expect(s.domain, ["red", "green"]);
  });

  test("ordinal.domain() returns a copy of the domain", () {
    final s = ScaleOrdinal()..domain = ["red", "green"];
    final domain = s.domain;
    s("blue");
    expect(domain, ["red", "green"]);
  });

  test("ordinal.domain() replaces previous domain values", () {
    final s = ScaleOrdinal()..range = ["foo", "bar"];
    expect(s(1), "foo");
    expect(s(0), "bar");
    expect(s.domain, [1, 0]);
    s.domain = ["0", "1"];
    expect(s("0"), "foo"); // it changed!
    expect(s("1"), "bar");
    expect(s.domain, ["0", "1"]);
  });

  test("ordinal.domain() does not coerce domain values to strings", () {
    final s = ScaleOrdinal()..domain = [0, 1];
    expect(s.domain, [0, 1]);
    expect(s.domain[0], isA<num>());
    expect(s.domain[1], isA<num>());
  });

  test("ordinal.domain() does not barf on object built-ins", () {
    final s = ScaleOrdinal()
      ..domain = ["__proto__", "hasOwnProperty"]
      ..range = [42, 43];
    expect(s("__proto__"), 42);
    expect(s("hasOwnProperty"), 43);
    expect(s.domain, ["__proto__", "hasOwnProperty"]);
  });

  test("ordinal() accepts dates", () {
    final s = ScaleOrdinal();
    s(DateTime(1970, 3, 1));
    s(DateTime(2001, 5, 13));
    s(DateTime(1970, 3, 1));
    s(DateTime(2001, 5, 13));
    expect(s.domain, [DateTime(1970, 3, 1), DateTime(2001, 5, 13)]);
  });

  test("ordinal.domain() accepts dates", () {
    final s = ScaleOrdinal()
      ..domain = [
        DateTime(1970, 3, 1),
        DateTime(2001, 5, 13),
        DateTime(1970, 3, 1),
        DateTime(2001, 5, 13)
      ];
    s(DateTime(1970, 3, 1));
    s(DateTime(1999, 12, 31));
    expect(s.domain,
        [DateTime(1970, 3, 1), DateTime(2001, 5, 13), DateTime(1999, 12, 31)]);
  });

  test("ordinal.domain() does not barf on object built-ins", () {
    final s = ScaleOrdinal()
      ..domain = ["__proto__", "hasOwnProperty"]
      ..range = [42, 43];
    expect(s("__proto__"), 42);
    expect(s("hasOwnProperty"), 43);
    expect(s.domain, ["__proto__", "hasOwnProperty"]);
  });

  test("ordinal.domain() is ordered by appearance", () {
    final s = ScaleOrdinal();
    s("foo");
    s("bar");
    s("baz");
    expect(s.domain, ["foo", "bar", "baz"]);
    s.domain = ["baz", "bar"];
    s("foo");
    expect(s.domain, ["baz", "bar", "foo"]);
    s.domain = ["baz", "foo"];
    expect(s.domain, ["baz", "foo"]);
    s.domain = [];
    s("foo");
    s("bar");
    expect(s.domain, ["foo", "bar"]);
  });

  test("ordinal.range(x) makes a copy of the range", () {
    final range = ["red", "green"];
    final s = ScaleOrdinal()..range = range;
    range.add("blue");
    expect(s.range, ["red", "green"]);
  });

  test("ordinal.range() returns a copy of the range", () {
    final s = ScaleOrdinal()..range = ["red", "green"];
    final range = s.range;
    expect(range, ["red", "green"]);
    range.add("blue");
    expect(s.range, ["red", "green"]);
  });

  test("ordinal.range(values) does not discard implicit domain associations",
      () {
    final s = ScaleOrdinal();
    expect(s(0), null);
    expect(s(1), null);
    s.range = ["foo", "bar"];
    expect(s(1), "bar");
    expect(s(0), "foo");
  });

  test("ordinal(value) recycles values when exhausted", () {
    final s = ScaleOrdinal()..range = ["a", "b", "c"];
    expect(s(0), "a");
    expect(s(1), "b");
    expect(s(2), "c");
    expect(s(3), "a");
    expect(s(4), "b");
    expect(s(5), "c");
    expect(s(2), "c");
    expect(s(1), "b");
    expect(s(0), "a");
  });

  test("ordinal.unknown(x) sets the output value for unknown inputs", () {
    final s = ScaleOrdinal()
      ..domain = ["foo", "bar"]
      ..unknown = "gray"
      ..implicit = false
      ..range = ["red", "blue"];
    expect(s("foo"), "red");
    expect(s("bar"), "blue");
    expect(s("baz"), "gray");
    expect(s("quux"), "gray");
  });

  test(
      "ordinal.implicit(false) prevents implicit domain extension if x is not implicit",
      () {
    final s = ScaleOrdinal()
      ..domain = ["foo", "bar"]
      ..implicit = false
      ..range = ["red", "blue"];
    expect(s("baz"), null);
    expect(s.domain, ["foo", "bar"]);
  });

  test("ordinal.copy() copies all fields", () {
    final s1 = ScaleOrdinal()
      ..domain = [1, 2]
      ..range = ["red", "green"]
      ..unknown = "gray"
      ..implicit = false;
    final s2 = s1.copy();
    expect(s2.domain, s1.domain);
    expect(s2.range, s1.range);
    expect(s2.unknown, s1.unknown);
  });

  test("ordinal.copy() changes to the domain are isolated", () {
    final s1 = ScaleOrdinal()..range = ["foo", "bar"];
    final s2 = s1.copy();
    s1.domain = [1, 2];
    expect(s2.domain, []);
    expect(s1(1), "foo");
    expect(s2(1), "foo");
    s2.domain = [2, 3];
    expect(s1(2), "bar");
    expect(s2(2), "foo");
    expect(s1.domain, [1, 2]);
    expect(s2.domain, [2, 3]);
  });

  test("ordinal.copy() changes to the range are isolated", () {
    final s1 = ScaleOrdinal()..range = ["foo", "bar"];
    final s2 = s1.copy();
    s1.range = ["bar", "foo"];
    expect(s1(1), "bar");
    expect(s2(1), "foo");
    expect(s2.range, ["foo", "bar"]);
    s2.range = ["foo", "baz"];
    expect(s1(2), "foo");
    expect(s2(2), "baz");
    expect(s1.range, ["bar", "foo"]);
    expect(s2.range, ["foo", "baz"]);
  });
}
