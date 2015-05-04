import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";
import NumberUtils  from "../utils/number-utils";

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
    });

    this.preferredPair = this.preferences.preferredPair;
    this.update();
  }

  attach(slider) {
    slider.addObserver("propertyChanged", (n, e) => {
      if (e.key === "currentRange") {
        this.currentRange = e.newValue;
        this.update();
      }
    });

    this.currentRange = slider.currentRange;
    this.update();
  }

  update() {
    if (!this.currentRange || !this.preferredPair) return;
    this.rates.fetchRates(
      this.preferredPair,
      this.preferences.chartInterval,
      this.currentRange.start,
      this.currentRange.end
    ).then((data) => this.rateData = data );
  }

  set sticks(sticks) {
    this.setProperty("sticks", sticks);
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

  get axisLabels() {
    let range = this.coordinateCalculator.rateRange;
    const diff = (range.highest - range.lowest);
    let step   = CandleSticks.calculateStep( range.highest );
    while ( diff/step > 5 ) {
      if ( diff/step > 10 ) {
        step = step * 10;
      } else {
        step = step * 5;
      }
    }
    const start = (Math.ceil((range.lowest * 10000) / (step*10000)) * (step*10000))/10000;
    const results = [];
    for( let i=start; i < range.highest; i+=step ) {
      if (i <= range.lowest) continue;
      results.push({
        value:i,
        y:this.coordinateCalculator.calculateY(i)
      });
    }
    return results;
  }

  calculateHighAndLow(data) {
    const result = data.reduce((r, v) => {
      if (r.highest < v.high) r.highest = v.high;
      if (r.lowest  > v.low ) r.lowest = v.low;
      return r;
    }, {highest:data[0].high, lowest:data[0].low});
    const margin = this.calculateMargin(result);
    return {
      highest: result.highest + margin,
      lowest:  result.lowest  - margin
    };
  }

  calculateMargin(highAndLow) {
    const diff = (highAndLow.highest - highAndLow.lowest);
    const step = CandleSticks.calculateStep( highAndLow.highest );
    if ( diff <= step ) {
      return step;
    } else {
      return (highAndLow.highest - highAndLow.lowest) * 0.1;
    }
  }
  static calculateStep( rate ) {
    const positiveDigit = Math.max(NumberUtils.getPositiveDigits(rate), 1);
    return Math.pow(10, positiveDigit-5);
  }

  calculateSticks(data) {
    return data.map((item, i) =>{
      return {
        high:  this.coordinateCalculator.calculateY(item.high),
        low:   this.coordinateCalculator.calculateY(item.low),
        open:  this.coordinateCalculator.calculateY(item.open),
        close: this.coordinateCalculator.calculateY(item.close),
        isUp:  item.open < item.close,
        x:     this.coordinateCalculator.calculateX(item.timestamp)
      };
    });
  }

}
