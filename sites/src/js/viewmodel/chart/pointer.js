import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import Numbers              from "../../utils/numbers"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"
import CoordinateCalculator from "./coordinate-calculator"

export default class Pointer extends Observable {

  constructor(coordinateCalculator, candleSticks, graphs) {
    super();
    this.coordinateCalculator = coordinateCalculator;
    this.candleSticks         = candleSticks;
    this.graphs               = graphs;

    this.registerObservers();
  }

  registerObservers() {
    this.candleSticks.addObserver("propertyChanged", (n, e) => {
      if (e.key === "sticks") {
        if (!this.initializePointerIfNotInitialized()) {
          this.updateRate();
          this.updatePrice();
        }
      }
    }, this);
    this.graphs.addObserver("propertyChanged", (n, e) => {
      if (e.key === "lines") {
        this.updateBalance();
      }
    }, this);
  }

  attach(slider) {
    this.slider = slider;
    this.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key === "currentRange") {
        this.updateTime();
      } else if (e.key === "temporaryCurrentRange") {
        this.updateTime(e.newValue);
      }
    }, this);
  }

  initialize() {
    this.setProperty("time", null);
    this.setProperty("balance", null);
    this.setProperty("price", null);
    this.setProperty("rate", null);
    this.x = null;
    this.y = null;
  }

  unregisterObservers() {
    this.graphs.removeAllObservers(this);
    this.candleSticks.removeAllObservers(this);
    this.slider.removeAllObservers(this);
  }

  initializePointerIfNotInitialized() {
    if (this.x != null && this.y != null) return false;
    if (!this.candleSticks.sticks
      || this.candleSticks.sticks.length <= 0 ) return false;

    const last = this.candleSticks.sticks[this.candleSticks.sticks.length-1];
    this.setProperty("x",       last.x);
    this.setProperty("y",       last.close);
    this.setProperty("time",    last.data.timestamp);
    this.setProperty("price",   last.data.close.bid);
    this.setProperty("rate",    last);
    this.setProperty("balance", null);
    return true;
  }
  updateRate() {
    let rate = null
    if (this.x != null && this.candleSticks.sticks) {
      const x = this.x;
      rate = this.candleSticks.sticks.find((s) => s.x === x );
    }
    this.setProperty("rate", rate);
  }
  updateTime(range=null) {
    let time = null
    if (this.x != null) {
      time = this.coordinateCalculator.calculateTime(this.x, range);
    }
    this.setProperty("time", time);
  }
  updatePrice() {
    let price = null
    if (this.y != null && this.coordinateCalculator.isRateArea(this.y)) {
      price = this.coordinateCalculator.calculatePrice(this.y);
    }
    this.setProperty("price", price);
  }
  updateBalance() {
    let balance = null
    if (this.y != null && this.coordinateCalculator.isProfitArea(this.y)) {
      let graph = null;
      this.graphs.graphs.forEach((g) => {
        if (g.type == "balance" ) graph = g;
      });
      if (graph) {
        balance = graph.coordinateCalculator.calculateValue(this.y);
      }
    }
    this.setProperty("balance", balance);
  }

  set x(x) {
    this.setProperty("x", this.normalizeX(x));
    this.updateTime();
    this.updateRate();
    this.requestRefresh();
  }
  get x() {
    return this.getProperty("x");
  }
  set y(y) {
    this.setProperty("y", this.normalizeY(y));
    this.updatePrice();
    this.updateBalance();
    this.requestRefresh();
  }
  get y() {
    return this.getProperty("y");
  }
  get time() {
    return this.getProperty("time");
  }
  get rate() {
    return this.getProperty("rate");
  }
  get price() {
    return this.getProperty("price");
  }
  get balance() {
    return this.getProperty("balance");
  }

  requestRefresh() {
    this.fire( "refresh" );
  }

  normalizeX(x) {
    if (x==null) return x;
    const sticeWidth   = CoordinateCalculator.stickWidthAndGap();
    const padding      = CoordinateCalculator.padding();
    const axisPosition = this.coordinateCalculator.axisPosition;
    if (x < padding) x = padding;
    if (x >= axisPosition.horizontal-sticeWidth) x = axisPosition.horizontal-sticeWidth;
    return Math.floor((x-padding)/sticeWidth)*sticeWidth+sticeWidth/2 + padding;
  }
  normalizeY(y) {
    if (y==null) return y;
    const padding      = CoordinateCalculator.padding();
    const axisPosition = this.coordinateCalculator.axisPosition;
    if (y < padding) y = padding;
    if (y >= axisPosition.vertical) y = axisPosition.vertical-1;
    return y;
  }
}
