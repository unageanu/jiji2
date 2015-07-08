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

  static formatPeriod(s) {
    if (s == null) return "";
    let str = "";
    [
      {label: "日",   period: 60 * 60 * 24},
      {label: "時間", period: 60 * 60},
      {label: "分",   period: 60},
      {label: "秒",   period: 0}
    ].forEach((p)=> {
      if (s >= p.period) {
        const step = Math.floor(p.period > 0 ? s/p.period : s);
        if (step !== 0) str = str + step + p.label;
        s = s % p.period;
      }
    });
    return str || "0秒";
  }
}
