import DateWithOffset from "date-with-offset"

const defaultTimezoneOffset = new Date().getTimezoneOffset()*-1;

export default class Dates {

  static date(iso8601String) {
    return new DateWithOffset(
      iso8601String, this.getTimezoneOffset() );
  }

  static getTimezoneOffset() {
    return this.timezoneOffset != null
        ? this.timezoneOffset
        : defaultTimezoneOffset;
  }
  static setTimezoneOffset(timezoneOffset) {
    this.timezoneOffset = timezoneOffset;
  }
  static resetTimezoneOffset() {
    this.timezoneOffset = null;
  }

  static isDateLikeObject(o) {
    return o && o.getTime && o.getTimezoneOffset;
  }

  static plusDays(date, n) {
    return new Date(date.getTime() + (1000 * 60 * 60 * 24 * n));
  }

  static truncate(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }
}
