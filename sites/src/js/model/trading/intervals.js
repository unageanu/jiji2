const m = 60 * 1000;
const intervals = [
  { id:"one_minute",      labelId:"oneMinute",       ms:       1 * m },
  { id:"fifteen_minutes", labelId:"fifteenMinutes",  ms:      15 * m },
  { id:"thirty_minutes",  labelId:"thirtyMinutes",   ms:      30 * m },
  { id:"one_hour",        labelId:"oneHour",         ms:      60 * m },
  { id:"six_hours",       labelId:"sixHours",        ms:  6 * 60 * m },
  { id:"one_day",         labelId:"oneDay",          ms: 24 * 60 * m }
];

export default class Intervals {

  static all() {
    return intervals;
  }
  static byId( id ) {
    return intervals.find( (item) => item.id === id );
  }

  static resolveCollectingInterval(intervalId) {
    return (this.byId( intervalId ) || intervals[0]).ms;
  }

}
