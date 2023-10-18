import 'package:d4_scale/src/identity.dart';
import 'package:test/test.dart';

void main() {
  test("ScaleIdentity() has the expected defaults", () {
    final s = ScaleIdentity();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
  });

  test("ScaleIdentity(range) sets the domain and range", () {
    final s = ScaleIdentity(range: [1, 2]);
    expect(s.domain, [1, 2]);
    expect(s.range, [1, 2]);
  });

  test("identity(x) is the identity function", () {
    final s = ScaleIdentity()..domain = [1, 2];
    expect(s(0.5), 0.5);
    expect(s(1), 1);
    expect(s(1.5), 1.5);
    expect(s(2), 2);
    expect(s(2.5), 2.5);
  });

  test("identity(undefined) returns unknown", () {
    final s = ScaleIdentity()..unknown = -1;
    expect(s(null), -1);
    expect(s(double.nan), -1);
    expect(s(0.4), 0.4);
  });

  test("identity.invert(y) is the identity function", () {
    final s = ScaleIdentity()..domain = [1, 2];
    expect(s.invert(0.5), 0.5);
    expect(s.invert(1), 1);
    expect(s.invert(1.5), 1.5);
    expect(s.invert(2), 2);
    expect(s.invert(2.5), 2.5);
  });

  test("identity.domain() is an alias for range()", () {
    final s = ScaleIdentity();
    expect(s.domain, s.range);
    s.domain = [-10, 0, 100];
    expect(s.range, [-10, 0, 100]);
    s.range = [-10, 0, 100];
    expect(s.domain, [-10, 0, 100]);
  });

  test("identity.domain() defaults to [0, 1]", () {
    final s = ScaleIdentity();
    expect(s.domain, [0, 1]);
    expect(s.range, [0, 1]);
    expect(s(0.5), 0.5);
  });

  test("identity.domain() can specify a polyidentity domain and range", () {
    final s = ScaleIdentity()..domain = [-10, 0, 100];
    expect(s.domain, [-10, 0, 100]);
    expect(s(-5), -5);
    expect(s(50), 50);
    expect(s(75), 75);
    s.range = [-10, 0, 100];
    expect(s.range, [-10, 0, 100]);
    expect(s(-5), -5);
    expect(s(50), 50);
    expect(s(75), 75);
  });

  test("identity.domain() does not affect the identity function", () {
    final s = ScaleIdentity()..domain = [double.infinity, double.nan];
    expect(s(42), 42);
    expect(s.invert(-42), -42);
  });

  test("identity.ticks(count) generates ticks of varying degree", () {
    final s = ScaleIdentity();
    expect(s.ticks(1).map(s.tickFormat(1)), ["0", "1"]);
    expect(s.ticks(2).map(s.tickFormat(2)), ["0.0", "0.5", "1.0"]);
    expect(s.ticks(5).map(s.tickFormat(5)),
        ["0.0", "0.2", "0.4", "0.6", "0.8", "1.0"]);
    expect(s.ticks(10).map(s.tickFormat(10)), [
      "0.0",
      "0.1",
      "0.2",
      "0.3",
      "0.4",
      "0.5",
      "0.6",
      "0.7",
      "0.8",
      "0.9",
      "1.0"
    ]);
    s.domain = [1, 0];
    expect(s.ticks(1).map(s.tickFormat(1)), ["0", "1"].reversed.toList());
    expect(s.ticks(2).map(s.tickFormat(2)),
        ["0.0", "0.5", "1.0"].reversed.toList());
    expect(s.ticks(5).map(s.tickFormat(5)),
        ["0.0", "0.2", "0.4", "0.6", "0.8", "1.0"].reversed.toList());
    expect(
        s.ticks(10).map(s.tickFormat(10)),
        [
          "0.0",
          "0.1",
          "0.2",
          "0.3",
          "0.4",
          "0.5",
          "0.6",
          "0.7",
          "0.8",
          "0.9",
          "1.0"
        ].reversed.toList());
  });

  test(
      "identity.tickFormat(count) formats ticks with the appropriate precision",
      () {
    final s = ScaleIdentity()..domain = [0.123456789, 1.23456789];
    expect(s.tickFormat(1)(s.ticks(1)[0]), "1");
    expect(s.tickFormat(2)(s.ticks(2)[0]), "0.5");
    expect(s.tickFormat(4)(s.ticks(4)[0]), "0.2");
    expect(s.tickFormat(8)(s.ticks(8)[0]), "0.2");
    expect(s.tickFormat(16)(s.ticks(16)[0]), "0.15");
    expect(s.tickFormat(32)(s.ticks(32)[0]), "0.15");
    expect(s.tickFormat(64)(s.ticks(64)[0]), "0.14");
    expect(s.tickFormat(128)(s.ticks(128)[0]), "0.13");
    expect(s.tickFormat(256)(s.ticks(256)[0]), "0.125");
  });

  test("identity.copy() isolates changes to the domain or range", () {
    final s1 = ScaleIdentity();
    final s2 = s1.copy();
    final s3 = s1.copy();
    s1.domain = [1, 2];
    expect(s2.domain, [0, 1]);
    s2.domain = [2, 3];
    expect(s1.domain, [1, 2]);
    expect(s2.domain, [2, 3]);
    final s4 = s3.copy();
    s3.range = [1, 2];
    expect(s4.range, [0, 1]);
    s4.range = [2, 3];
    expect(s3.range, [1, 2]);
    expect(s4.range, [2, 3]);
  });
}
