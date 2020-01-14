import 'package:intl/intl.dart';

// <2006-11-01 Wed 19:15>
// <2006-11-02 Thu 20:00-22:00>
// <2004-08-23 Mon>--<2004-08-26 Thu>
// TODO: Implement repeating DateTimes <2007-05-16 Wed 12:30 +1w>
bool isSameDate(DateTime a, DateTime b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isDateOnly(DateTime dt) {
  return dt.hour == 0 && dt.minute == 0 && dt.second == 0 && dt.millisecond == 0 && dt.microsecond == 0;
}

var _dateFormatter = new DateFormat('yyyy-MM-dd E');
var _dateTimeFormatter = new DateFormat('yyyy-MM-dd EEE HH:mm');
var _dateHourFormatter = new DateFormat('HH:mm');

String formatCompact(DateTime dt) {
  if (isDateOnly(dt)) {
    return _dateFormatter.format(dt);
  } else {
    return _dateTimeFormatter.format(dt);
  }
}

String toOrgDateTimeString(DateTime start, end) {
  if (end == null || isSameDate(start, end)) {
    // we compress range into same stamp
    if (end == null || isDateOnly(end)) {
      // we only need the start stamp
      return "<${formatCompact(start)}>";
    }
    return "<${formatCompact(start)}-${_dateHourFormatter.format(end)}>";
  }

  // We need 2 stamps
  return "<${formatCompact(start)}>--<${formatCompact(end)}>";
}

class Timestamp {
  final String _date = r"\d{4}-\d{2}-\d{2}";
  final String _time = r"\d{2}:\d{2}";
  final String _day = r"[a-zA-Z]+";
  final String _open = r"[<\[]";
  final String _close = r"[>\]]";

  String _single(String prefix) {
    return "${_open}"
    "(?<${prefix}Date>${_date})"
    "\\s+${_day}"
    "(?:\\s+(?<${prefix}TimeBegin>${_time})"
    "(?:-(?<${prefix}TimeEnd>${_time}))?)?"
    "${_close}";

  }

  String _full() {
    return "^\\s*"
    "(${_single('begin')})"
    "(?:--${_single('end')})?"
    "\\s*\$";
  }

  RegExp get regexp {
    return RegExp(_full(), caseSensitive: false);
  }
}

class ParsedDate {
  DateTime date;
  DateTime end;

  ParsedDate(this.date, this.end);
}

var _TIMESTAMP_REGEX = Timestamp().regexp;


DateTime _parseDate(String date, String time) {
  var text = date;
  var format = "yyyy-MM-dd";
  if (time != null) {
    text += " ${time}";
    format += " HH:mm";
  }
  return new DateFormat(format, "en_US").parse(text);
}

ParsedDate parse({String input, RegExpMatch match}) {
  RegExpMatch m;
  if (input != null) {
    m = _TIMESTAMP_REGEX.firstMatch(input);
  } else if (match != null ){
    m = match;
  } else {
    throw("timestamp.parse expects either input or match to be defined");
  }

  if (m == null) return null;

  var beginDate = m.namedGroup("beginDate");
  var beginTimeBegin = m.namedGroup("beginTimeBegin");
  var beginTimeEnd = m.namedGroup("beginTimeEnd");
  var endDate = m.namedGroup("endDate");
  var endTimeBegin = m.namedGroup("endTimeBegin");

  var date = _parseDate(beginDate, beginTimeBegin);
  var end;
  if (beginTimeEnd != null) {
    end = _parseDate(beginDate,  beginTimeEnd);
  } else if (endDate != null) {
    end = _parseDate(endDate, endTimeBegin);
  } else {
    end = null;
  }

  return ParsedDate(date, end);
}