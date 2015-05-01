import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";

const padding           = 8 * 2;
const sideLabelWidth    = 48;
const bottomLabelheight = 16;
const stickWidth = 5;
const stickGap   = 1;

export default class CandleSticks extends Observable {
  constructor(rates, preferences) {
    super();
    this.rates       = rates;
    this.preferences = preferences;

    this.registerObservers();
  }

  static totalPaddingWidth() {
    return padding + sideLabelWidth;
  }
  static totalPaddingHeight() {
    return padding + bottomLabelheight;
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

  attachSlider(slider) {
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

  set stageSize( size ) {
    this.displayableCandleCount = this.calculateDisplayableCandleCount(size.w);
    return this.setProperty("stageSize", size);
  }
  get stageSize() {
    return this.getProperty("stageSize");
  }

  set displayableCandleCount( displayableCandleCount ) {
    return this.setProperty("displayableCandleCount", displayableCandleCount);
  }
  get displayableCandleCount() {
    return this.getProperty("displayableCandleCount");
  }


  set highestRate(value) {
    this.setProperty("highestRate", value);
  }
  get highestRate() {
    return this.getProperty("highestRate");
  }
  set lowestRate(value) {
    this.setProperty("lowestRate", value);
  }
  get lowestRate() {
    return this.getProperty("lowestRate");
  }

  set sticks(sticks) {
    this.setProperty("sticks", sticks);
  }
  get sticks() {
    return this.getProperty("sticks");
  }

  set rateData(data) {
    const result = this.calculateHighAndLow(data);
    this.highestRate = result.highest;
    this.lowestRate  = result.lowest;

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
    const height        = this.stageSize.h - CandleSticks.totalPaddingHeight();
    const pricePerPixel = (this.highestRate - this.lowestRate) / height;
    return data.map((item, i) =>{
      return {
        high:  this.calculateY(pricePerPixel, item.high),
        low:   this.calculateY(pricePerPixel, item.low),
        open:  this.calculateY(pricePerPixel, item.open),
        close: this.calculateY(pricePerPixel, item.close),
        isUp:  item.open < item.close,
        x:     i*6 + 3
      };
    });
  }

  calculateY( pricePerPixel, price ) {
    return Math.floor( (this.highestRate - price) / pricePerPixel );
  }

  calculateDisplayableCandleCount( stageWidth ) {
    return Math.floor((stageWidth - CandleSticks.totalPaddingWidth() )
                    / (stickWidth + stickGap));
  }
}
