import 'dart:math';

import 'package:d4_interpolate/d4_interpolate.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:test/test.dart';

void main() {
  test("ScalePow.sqrt() has the expected defaults", () {
    final s = ScalePow<num>.sqrt(range: [0, 1], interpolate: interpolateNumber);
    expect(s.domain, [0, 1]);
    expect(s.clamp, false);
    expect(s.exponent, 0.5);
  });

  test("sqrt(x) maps a domain value x to a range value y", () {
    expect(ScalePow.sqrt(range: [0, 1], interpolate: interpolateNumber)(0.5),
        sqrt1_2);
  });
}
