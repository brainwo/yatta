/// Used to calculate YouTube video age
/// Returns [String]
/// ```dart
/// timeSince(DateTime., DateTime.now());
/// ```
String timeSince(final DateTime startTime, final DateTime endTime) {
  final duration = startTime.difference(endTime);

  // Average days in a year based on Julian calendar, true length of a year on
  // Earth is actually 365.2422 days
  const daysInYear = 365.25;
  // Average days in a month
  const daysInMonth = 30.4375;
  const daysInWeek = 7;

  final days = duration.inDays.abs();
  final hours = duration.inHours.abs();
  final minutes = duration.inMinutes.abs();
  final seconds = duration.inSeconds.abs();

  final buff = StringBuffer();

  if (!duration.isNegative) {
    buff.write('in ');
  }

  if (days >= daysInYear * 2) {
    buff.write('${(days / daysInYear).floor()} years');
  } else if (days >= daysInYear) {
    buff.write('1 year');
  } else if (days >= daysInMonth * 2) {
    buff.write('${(days / daysInMonth).floor()} months');
  } else if (days >= daysInMonth) {
    buff.write('1 month');
  } else if (days >= daysInWeek * 2) {
    buff.write('${(days / daysInWeek).floor()} weeks');
  } else if (days >= daysInWeek) {
    buff.write('1 week');
  } else if (days >= 2) {
    buff.write('$days days');
  } else if (days == 1) {
    buff.write('1 day');
  } else if (hours >= 2) {
    buff.write('$hours hours');
  } else if (hours == 1) {
    buff.write('$hours hour');
  } else if (minutes >= 2) {
    buff.write('$minutes minutes');
  } else if (minutes == 1) {
    buff.write('1 minute');
  } else if (seconds >= 2) {
    buff.write('$seconds seconds');
  } else if (seconds == 1) {
    buff.write('1 second');
  } else {
    buff.write('less than a second');
  }

  if (duration.isNegative) {
    buff.write(' ago');
  }

  return buff.toString();
}
