import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import Numbers              from "../../utils/numbers"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"


export default class Context extends Observable {

constructor() {
    super();
  }

  get range() {
    return this.getProperty("range");
  }

  static createRmtContext(rates) {
    return new RmtContext(rates);
  }
  static createBacktestContext(backtest) {
    return new BackTestContext(backtest);
  }
}

class RmtContext extends Context{

  constructor(rates) {
    super(null);
    this.rates = rates;

    this.registerObservers();
  }
  initialize() {
    return this.rates.initialize();
  }
  registerObservers() {
    this.rates.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "range") return;
      this.setProperty("range", e.newValue);
    }, this);
  }
  unregisterObservers() {
    this.rates.removeAllObservers(this);
  }

  get backtestId() {
    return null;
  }
}

class BackTestContext extends Context {
  constructor(backtest) {
    super(null);
    this.backtest = backtest;

    this.setProperty("range", {
      start: backtest.start_time,
      end: backtest.end_time
    });
  }
  initialize() {
    return this.rates.initialize();
  }
  registerObservers() {}
  unregisterObservers() {}

  get backtestId() {
    return this.backtest.id;
  }
}
