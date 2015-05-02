import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";

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

  calculateHighAndLow(data) {
    const result = data.reduce((r, v) => {
      if (r.highest < v.high) r.highest = v.high;
      if (r.lowest  > v.low ) r.lowest = v.low;
      return r;
    }, {highest:data[0].high, lowest:data[0].low});
    const margin = (result.highest - result.lowest) * 0.1;
    return {
      highest: result.highest + margin,
      lowest:  result.lowest  - margin
    };
  }

  calculateSticks(data) {
    return data.map((item, i) =>{
      return {
        high:  this.coordinateCalculator.calculateY(item.high),
        low:   this.coordinateCalculator.calculateY(item.low),
        open:  this.coordinateCalculator.calculateY(item.open),
        close: this.coordinateCalculator.calculateY(item.close),
        isUp:  item.open < item.close,
        x:     i*6+3 //this.coordinateCalculator.calculateX(item.timestamp)
      };
    });
  }

}
