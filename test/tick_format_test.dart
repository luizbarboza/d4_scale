import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("tickFormat(start, stop, count) returns a format suitable for the ticks",
      () {
    expect(tickFormat(0, 1, 10)(0.2), "0.2");
    expect(tickFormat(0, 1, 20)(0.2), "0.20");
    expect(tickFormat(-100, 100, 10)(-20), "−20");
  });

  test(
      "tickFormat(start, stop, count, specifier) sets the appropriate fixed precision if not specified",
      () {
    expect(tickFormat(0, 1, 10, "+f")(0.2), "+0.2");
    expect(tickFormat(0, 1, 20, "+f")(0.2), "+0.20");
    expect(tickFormat(0, 1, 10, "+%")(0.2), "+20%");
    expect(tickFormat(0.19, 0.21, 10, "+%")(0.2), "+20.0%");
  });

  test(
      "tickFormat(start, stop, count, specifier) sets the appropriate round precision if not specified",
      () {
    expect(tickFormat(0, 9, 10, "")(2.10), "2");
    expect(tickFormat(0, 9, 100, "")(2.01), "2");
    expect(tickFormat(0, 9, 100, "")(2.11), "2.1");
    expect(tickFormat(0, 9, 10, "e")(2.10), "2e+0");
    expect(tickFormat(0, 9, 100, "e")(2.01), "2.0e+0");
    expect(tickFormat(0, 9, 100, "e")(2.11), "2.1e+0");
    expect(tickFormat(0, 9, 10, "g")(2.10), "2");
    expect(tickFormat(0, 9, 100, "g")(2.01), "2.0");
    expect(tickFormat(0, 9, 100, "g")(2.11), "2.1");
    expect(tickFormat(0, 9, 10, "r")(2.10e6), "2000000");
    expect(tickFormat(0, 9, 100, "r")(2.01e6), "2000000");
    expect(tickFormat(0, 9, 100, "r")(2.11e6), "2100000");
    expect(tickFormat(0, 0.9, 10, "p")(0.210), "20%");
    expect(tickFormat(0.19, 0.21, 10, "p")(0.201), "20.1%");
  });

  test(
      "tickFormat(start, stop, count, specifier) sets the appropriate prefix precision if not specified",
      () {
    expect(tickFormat(0, 1e6, 10, "\$s")(0.51e6), "\$0.5M");
    expect(tickFormat(0, 1e6, 100, "\$s")(0.501e6), "\$0.50M");
  });

  test(
      "tickFormat(start, stop, count) uses the default precision when the domain is invalid",
      () {
    final f = tickFormat(0, double.nan, 10);
    expect(f(0.12), "0.120000");
  });
}
