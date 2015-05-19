const m = 60 * 1000;
const intervals = [
  { id:"one_minute",      name:"分足",    ms:       1 * m },
  { id:"fifteen_minutes", name:"15分足",  ms:      15 * m },
  { id:"thirty_minutes",  name:"30分足",  ms:      30 * m },
  { id:"one_hour",        name:"1時間足", ms:      60 * m },
  { id:"six_hours",       name:"6時間足", ms:  6 * 60 * m },
  { id:"one_day",         name:"日足",    ms: 24 * 60 * m }
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
