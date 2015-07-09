import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import Numbers              from "../../utils/numbers"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"

export default class CandleSticks extends Observable {

  constructor(coordinateCalculator, rates, preferences) {
    super();
    this.rates                = rates;
    this.preferences          = preferences;
    this.coordinateCalculator = coordinateCalculator;

    this.registerObservers();
  }

  registerObservers() {
    this.preferences.addObserver("propertyChanged", (n, e) => {
      if (e.key === "preferredPairs") {
        this.preferredPair = this.preferences.preferredPair;
        this.update();
      }
    }, this);

    this.preferredPair = this.preferences.preferredPair;
    this.update();
  }

  attach(slider) {
    this.slider = slider;
    this.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key === "currentRange") {
        this.currentRange = e.newValue;
        this.update();
      }
    }, this);

    this.currentRange = slider.currentRange;
    this.update();
  }

  unregisterObservers() {
    this.preferences.removeAllObservers(this);
    this.slider.removeAllObservers(this);
  }

  update() {
    if (!this.currentRange || !this.preferredPair) return;
    this.coordinateCalculator.prepareUpdate();
    this.rates.fetchRates(
      this.preferredPair,
      this.preferences.chartInterval,
      this.currentRange.start,
      this.currentRange.end
    ).then((data) => this.rateData = data );
  }

  set sticks(sticks) {
    this.setProperty("sticks", sticks, () => false);
  }
  get sticks() {
    return this.getProperty("sticks");
  }

  set rateData(data) {
    this.coordinateCalculator.rateRange = this.calculateHighAndLow(data);
    this.sticks      = this.calculateSticks(data);
    this.getProperty("rateData", data);
  }
  get rateData() {
    return this.getProperty("rateData");
  }

  get verticalAxisLabels() {
    let range  = this.coordinateCalculator.rateRange;
    const diff = (range.highest - range.lowest);
    let step   = CandleSticks.calculateStep( range.highest );
    step       = CandleSticks.adjustStep( step, diff );
    return this.createVerticalAxisLabels(step, range);
  }

  get horizontalAxisLabels() {
    const intervalMs = Intervals.resolveCollectingInterval(
      this.preferences.chartInterval) * 8;
    return this.createHorizontalAxisLabels(intervalMs, this.currentRange);
  }

  get axisPosition() {
    return this.coordinateCalculator.axisPosition;
  }

  createVerticalAxisLabels(step, range) {
    const start = (Math.ceil((range.lowest * 10000) / (step*10000)) * (step*10000))/10000;
    const results = [];
    for( let i=start; i < range.highest; i+=step ) {
      if (i <= range.lowest) continue;
      results.push({
        value: Numbers.round(i, 6),
        y:     this.coordinateCalculator.calculateY(i)
      });
    }
    return results;
  }
  createHorizontalAxisLabels(step, range) {
    const start = Math.ceil(range.start.getTime() / step) * step;
    const results = [];
    for( let i=start; i < range.end.getTime(); i+=step ) {
      if (i <= range.start.getTime()) continue;
      const date = Dates.date(i);
      results.push({
        value: this.formatHorizontalAxisLAbel(date, step),
        x:     this.coordinateCalculator.calculateX(date, range)
      });
    }
    return results;
  }

  createHorizontalAxisLabelsByTemporaryRange(range) {
    const intervalMs = Intervals.resolveCollectingInterval(
      this.preferences.chartInterval) * 8;
    return this.createHorizontalAxisLabels(intervalMs, range);
  }

  formatHorizontalAxisLAbel(date, step) {
    const day = 24 * 60 * 60 * 1000;
    if (step >= day) {
      return DateFormatter.formatDateMMDD(date);
    } else {
      let result = DateFormatter.formatTimeHHMM(date);
      if ( date.getDate() !== Dates.date(date.getTime()-step).getDate() ) {
        result = DateFormatter.formatDateMMDD(date) + " " + result;
      }
      return result;
    }
  }

  calculateHighAndLow(data) {
    const result = data.reduce((r, v) => {
      if (r.highest < v.high.bid) r.highest = v.high.bid;
      if (r.lowest  > v.low.bid ) r.lowest = v.low.bid;
      return r;
    }, {highest:data[0].high.bid, lowest:data[0].low.bid});
    const margin = this.calculateMargin(result);
    return {
      highest: result.highest + margin,
      lowest:  result.lowest  - margin
    };
  }

  calculateMargin(highAndLow) {
    const diff = (highAndLow.highest - highAndLow.lowest);
    const step = CandleSticks.calculateStep( highAndLow.highest )*10;
    if ( diff <= step ) {
      return step;
    } else {
      return (highAndLow.highest - highAndLow.lowest) * 0.1;
    }
  }

  /**
   * 軸ラベルが3以下になるように、調整する。
   */
  static adjustStep( step, diff ) {
    let s     = step;
    for (let count = diff/s; count > 3; count = diff/s) {
      if ( count > 10 ) {
        s = s * 10;
      } else if ( count > 5 ) {
        s = s * 5;
      } else {
        s = s * 2;
      }
    }
    if ( diff/s < 2 ) {
      s = s / 2;
    }
    return s;
  }

  static calculateStep( rate ) {
    const positiveDigit = Math.max(Numbers.getPositiveDigits(rate), 1);
    return Math.pow(10, positiveDigit-6);
  }

  calculateSticks(data) {
    return data.map((item, i) =>{
      return {
        high:  this.coordinateCalculator.calculateY(item.high.bid),
        low:   this.coordinateCalculator.calculateY(item.low.bid),
        open:  this.coordinateCalculator.calculateY(item.open.bid),
        close: this.coordinateCalculator.calculateY(item.close.bid),
        isUp:  item.open.bid < item.close.bid,
        x:     this.coordinateCalculator.calculateX(item.timestamp)
      };
    });
  }

}
