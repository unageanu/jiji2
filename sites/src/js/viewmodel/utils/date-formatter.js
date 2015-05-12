import DateFormat from "date-format"

export default class DateFormatter {

  static formatDateMMDD(date) {
    return DateFormatter.format(date, "MM-dd");
  }
  static formatDateYYYYMMDD(date) {
    return DateFormatter.format(date, "yyyy-MM-dd");
  }
  static formatTimeHHMM(date) {
    return DateFormatter.format(date, "hh:mm");
  }
  static formatTimeHHMMSS(date) {
    return DateFormatter.format(date, "hh:mm:ss");
  }

  static format(date, format="yyyy-MM-dd hh:mm:ss") {
    if (!date) return "-";
    return DateFormat.asString(format, date);
  }
}
