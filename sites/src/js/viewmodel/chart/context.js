import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import Numbers              from "../../utils/numbers"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"


export default class Context extends Observable {

  constructor(rates, config) {
    super();
    this.rates = rates;

    this.displaySubGraph = config.displaySubGraph;

    this.registerObservers();
  }
  initialize() {
    return this.rates.initialize();
  }
  registerObservers() {
    this.rates.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "range") return;
      if (!this.backtest) this.setProperty("range", e.newValue);
    }, this);
  }
  unregisterObservers() {
    this.rates.removeAllObservers(this);
  }

  get range() {
    return this.getProperty("range");
  }
  set range(range) {
    this.setProperty("range", range);
  }

  get backtestId() {
    return this.backtest ? this.backtest.id : "rmt";
  }

  get backtest() {
    return this.getProperty("backtest");
  }
  set backtest(backtest) {
    this.setProperty("backtest", backtest);
    if (backtest == null) {
      this.setProperty("range", this.rates.range, () => false);
    } else {
      this.setProperty("range", {
        start: backtest.startTime,
        end: backtest.endTime
      }, ()=> false);
    }
  }
}
