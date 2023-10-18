import 'package:d4_array/d4_array.dart';
import 'package:d4_interpolate/d4_interpolate.dart';
import 'package:d4_time/d4_time.dart';
import 'package:d4_time_format/d4_time_format.dart';

import 'continuous.dart';
import 'interpolator.dart';
import 'linear.dart';
import 'nice.dart';

final _formatMillisecond = timeFormat(".%L"),
    _formatSecond = timeFormat(":%S"),
    _formatMinute = timeFormat("%I:%M"),
    _formatHour = timeFormat("%I %p"),
    _formatDay = timeFormat("%a %d"),
    _formatWeek = timeFormat("%b %d"),
    _formatMonth = timeFormat("%B"),
    _formatYear = timeFormat("%Y");

String _tickFormat(DateTime date) {
  return (timeSecond(date).isBefore(date)
      ? _formatMillisecond
      : timeMinute(date).isBefore(date)
          ? _formatSecond
          : timeHour(date).isBefore(date)
              ? _formatMinute
              : timeDay(date).isBefore(date)
                  ? _formatHour
                  : timeMonth(date).isBefore(date)
                      ? (timeWeek(date).isBefore(date)
                          ? _formatDay
                          : _formatWeek)
                      : timeYear(date).isBefore(date)
                          ? _formatMonth
                          : _formatYear)(date);
}

abstract base class _Calendar<Y> extends ScaleContinuousBase<DateTime, Y> {
  _Calendar(
      {required super.domain,
      required super.range,
      required super.interpolate}) {
    transform(identity, identity);
    _rescale();
  }

  void _rescale() {
    final d0 = domain[0];
    numberize(
      (t) => t.millisecondsSinceEpoch,
      (t) => DateTime.fromMillisecondsSinceEpoch(t.floor(), isUtc: d0.isUtc),
    );
  }

  @override
  set domain(domain) {
    super.domain = domain;
    _rescale();
  }

  /// Returns representative dates from the scale’s domain.
  ///
  /// ```dart
  /// final x = ScaleTime(domain: []);
  /// x.ticks(10);
  /// // [Sat Jan 01 2000 00:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 03:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 06:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 09:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 12:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 15:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 18:00:00 GMT-0800 (PST),
  /// //  Sat Jan 01 2000 21:00:00 GMT-0800 (PST),
  /// //  Sun Jan 02 2000 00:00:00 GMT-0800 (PST)]
  /// ```
  ///
  /// The returned tick values are uniformly-spaced (mostly), have sensible
  /// values (such as every day at midnight), and are guaranteed to be within
  /// the extent of the domain. Ticks are often used to display reference lines,
  /// or tick marks, in conjunction with the visualized data.
  ///
  /// An optional [countOrInterval] may be specified to affect how many ticks
  /// are generated. If [countOrInterval] is not specified, it defaults to 10.
  /// The specified `count` is only a hint; the scale may return more or fewer
  /// values depending on the domain.
  ///
  /// The following time intervals are considered for automatic ticks:
  ///
  /// * 1-, 5-, 15- and 30-second.
  /// * 1-, 5-, 15- and 30-minute.
  /// * 1-, 3-, 6- and 12-hour.
  /// * 1- and 2-day.
  /// * 1-week.
  /// * 1- and 3-month.
  /// * 1-year.
  ///
  /// In lieu of a `count`, a [TimeInterval] may be explicitly specified. To
  /// prune the generated ticks for a given time interval, use
  /// [TimeInterval.every]. For example, to generate ticks at 15-minute
  /// intervals:
  ///
  /// ```dart
  /// final x = ScaleTime(
  ///   domain: [DateTime.utc(2000, 1, 1, 0), DateTime.utc(2000, 1, 1, 2)],
  ///   range: [0, 1],
  ///   interpolate: interpolate,
  /// );
  /// x.ticks(timeMinute.every(15));
  /// // [2000-01-01T00:00Z,
  /// //  2000-01-01T00:15Z,
  /// //  2000-01-01T00:30Z,
  /// //  2000-01-01T00:45Z,
  /// //  2000-01-01T01:00Z,
  /// //  2000-01-01T01:15Z,
  /// //  2000-01-01T01:30Z,
  /// //  2000-01-01T01:45Z,
  /// //  2000-01-01T02:00Z]
  /// ```
  ///
  /// Note: in some cases, such as with day ticks, specifying a *step* can
  /// result in irregular spacing of ticks because time intervals have varying
  /// length.
  @override
  ticks([Object? countOrInterval]) {
    var d = domain;
    return countOrInterval is TimeInterval
        ? timeRange(d[0], d[d.length - 1], countOrInterval)
        : timeTicks(d[0], d[d.length - 1], (countOrInterval as num?) ?? 10);
  }

  /// Returns a time format function suitable for displaying [ticks].
  ///
  /// ```dart
  /// final x = ScaleTime(
  ///   domain: [DateTime.utc(2000, 1, 1, 0), DateTime.utc(2000, 1, 1, 2)],
  ///   range: [0, 1],
  ///   interpolate: interpolate,
  /// );
  /// final T = x.ticks(timeMinute.every(15));
  /// final f = x.tickFormat();
  /// T.map(f); // ["2000", "12:15", "12:30", "12:45", "01 AM", "01:15", "01:30", "01:45", "02 AM"]
  /// ```
  ///
  /// The specified [count] is currently ignored, but is accepted for
  /// consistency with other scales such as [ScaleLinear.tickFormat]. If a
  /// format [specifier] is specified, this method is equivalent to format. If
  /// [specifier] is not specified, the default time format is returned. The
  /// default multi-scale time format chooses a human-readable representation
  /// based on the specified date as follows:
  ///
  /// ```dart
  /// * `%Y` - for year boundaries, such as `2011`.
  /// * `%B` - for month boundaries, such as `February`.
  /// * `%b %d` - for week boundaries, such as `Feb 06`.
  /// * `%a %d` - for day boundaries, such as `Mon 07`.
  /// * `%I %p` - for hour boundaries, such as `01 AM`.
  /// * `%I:%M` - for minute boundaries, such as `01:23`.
  /// * `:%S` - for second boundaries, such as `:45`.
  /// * `.%L` - milliseconds for all other times, such as `.012`.
  /// ```
  ///
  /// Although somewhat unusual, this default behavior has the benefit of
  /// providing both local and global context: for example, formatting a
  /// sequence of ticks as \[11 PM, Mon 07, 01 AM\] reveals information about
  /// hours, dates, and day simultaneously, rather than just the hours
  /// \[11 PM, 12 AM, 01 AM\]. See
  /// [d4_time_format](https://pub.dev/documentation/d4_time_format/latest/d4_time_format/d4_time_format-library.html) if
  /// you’d like to roll your own conditional time format.
  @override
  tickFormat([count = 10, specifier]) {
    if (specifier == null) return _tickFormat;

    final f = timeFormat(specifier);
    return (d) => f(d);
  }

  /// Extends the domain so that it starts and ends on nice round values.
  ///
  /// ```dart
  /// final x = ScaleTime(
  ///   domain: [
  ///     DateTime.utc(2000, 1, 1, 12, 34),
  ///     DateTime.utc(2000, 1, 1, 12, 59)
  ///  ],
  ///   range: [0, 1],
  ///   interpolate: interpolateNumber,
  /// )..nice();
  /// x.domain; // [2000-01-01T12:30Z, 2000-01-01T13:00Z]
  /// ```
  ///
  /// This method typically modifies the scale’s domain, and may only extend the
  /// bounds to the nearest round value. See [ScaleLinear.nice] for more.
  ///
  /// An optional tick count argument allows greater control over the step size
  /// used to extend the bounds, guaranteeing that the returned [ticks] will
  /// exactly cover the domain. Alternatively, a time interval may be specified
  /// to explicitly set the ticks. If an interval is specified, an optional step
  /// may also be specified to skip some ticks. For example,
  /// *time*.nice(timeSecond.every(10)) will extend the domain to an even ten
  /// seconds (0, 10, 20, etc.). See [ticks] and [TimeInterval.every] for
  /// further detail.
  ///
  /// Nicing is useful if the domain is computed from data, say using [extent],
  /// and may be irregular. For example, for a domain of \[2009-07-13T00:02,
  /// 2009-07-13T23:48\], the nice domain is \[2009-07-13, 2009-07-14\]. If the
  /// domain has more than two values, nicing the domain only affects the first
  @override
  nice([Object? countOrInterval]) {
    var d = domain;
    final interval = countOrInterval is TimeInterval
        ? countOrInterval
        : timeTickInterval(
            d[0], d[d.length - 1], (countOrInterval as num?) ?? 10);
    if (interval != null) {
      domain = nicee(d, (floor: interval, ceil: interval.ceil));
    }
  }
}

/// Time scales are a variant of
/// [linear scales](https://pub.dev/documentation/d4_scale/latest/topics/Diverging%20scales-topic.html)
/// that have a temporal domain.
///
/// Time scales implement ticks based on calendar intervals, taking the pain out
/// of generating axes for temporal domains.
///
/// {@category Time scales}
final class ScaleTime<Y> extends _Calendar<Y> {
  /// Constructs a new linear scale with the specified [domain], [range] and
  /// [interpolate], and [clamp]ing disabled.
  ///
  /// For example, to create a position encoding:
  ///
  /// ```dart
  /// final x = ScaleTime(
  ///   domain: [DateTime(2000, 1, 1).toUtc(), DateTime(2000, 1, 2).toUtc()],
  ///   range: [0, 960],
  ///   interpolate: interpolateNumber,
  /// );
  /// x(DateTime(2000, 1, 1, 5).toUtc()); // 200
  /// x(DateTime(2000, 1, 1, 16).toUtc()); // 640
  /// x.invert(200); // Sat Jan 01 2000 05:00:00 GMT-0800 (PST)
  /// x.invert(640); // Sat Jan 01 2000 16:00:00 GMT-0800 (PST)
  /// ```
  ///
  /// If [domain] is not specified, it defaults to \[2000-01-01, 2000-01-02\] in
  /// local time.
  ScaleTime(
      {List<DateTime>? domain,
      required super.range,
      required super.interpolate})
      : super(domain: domain ?? [DateTime(2000, 1, 1), DateTime(2000, 1, 1)]);

  @override
  ScaleTime<Y> copy() => assign(
      ScaleTime<Y>(
          domain: domain, range: this.range, interpolate: this.interpolate),
      this);

  static ScaleTime<num> number(
      {List<DateTime>? domain,
      List<num> range = const [0, 1],
      Interpolate<num> interpolate = interpolateNumber}) {
    return ScaleTime(domain: domain, range: range, interpolate: interpolate);
  }

  static ScaleTime<Object?> dynamic(
      {List<DateTime>? domain,
      List<Object?> range = const <num>[0, 1],
      Interpolate<Object?> interpolate = interpolate}) {
    return ScaleTime(domain: domain, range: range, interpolate: interpolate);
  }
}
