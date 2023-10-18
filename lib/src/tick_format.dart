import 'dart:math' as math;

import 'package:d4_array/d4_array.dart';
import 'package:d4_format/d4_format.dart';

/// Returns a
/// [number format](https://pub.dev/documentation/d4_format/latest/d4_format/d4_format-library.html)
/// function suitable for displaying a tick value, automatically computing the
/// appropriate precision based on the fixed interval between tick values, as
/// determined by [tickStep].
///
/// ```dart
/// final f = tickFormat(0, 1, 20);
/// f(1); // "1.00"
/// ```
///
/// An optional [specifier] allows a custom format where the precision of the
/// format is automatically set by the scale as appropriate for the tick
/// interval. For example, to format percentage change, you might say:
///
/// ```dart
/// final f = tickFormat(-1, 1, 5, "+%");
/// f(-0.5); // "-50%"
/// ```
///
/// If [specifier] uses the format type `s`, the scale will return a
/// SI-prefix format (see [FormatLocale.formatPrefix]) based on the larger
/// absolute value of [start] and [stop]. If the [specifier] already specifies a
/// precision, this method is equivalent to [FormatLocale.format].
///
/// {@category Linear scales}
String Function(num) tickFormat(num start, num stop, num count,
    [String? specifier]) {
  var step = tickStep(start, stop, count);

  num? precision;
  final specifier0 = FormatSpecifier.parse(specifier ?? ",f");
  switch (specifier0.type) {
    case "s":
      {
        var value = math.max(start.abs(), stop.abs());
        if (specifier0.precision == null &&
            !(precision = precisionPrefix(step, value)).isNaN) {
          specifier0.precision = precision as int;
        }
        return formatPrefix(specifier0.toString(), value);
      }
    case "":
    case "e":
    case "g":
    case "p":
    case "r":
      {
        if (specifier0.precision == null &&
            !(precision =
                    precisionRound(step, math.max(start.abs(), stop.abs())))
                .isNaN) {
          specifier0.precision =
              precision - (specifier0.type == "e" ? 1 : 0) as int;
        }
        break;
      }
    case "f":
    case "%":
      {
        if (specifier0.precision == null &&
            !(precision = precisionFixed(step)).isNaN) {
          specifier0.precision =
              precision - (specifier0.type == "%" ? 1 : 0) * 2 as int;
        }
        break;
      }
  }
  return format(specifier0.toString());
}
