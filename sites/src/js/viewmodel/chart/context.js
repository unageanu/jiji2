import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import Numbers              from "../../utils/numbers"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"


export default class Context extends Observable {

  constructor(backtestId) {
    super();
    this.backtestId = backtestId;
  }

  initialize() {}

  get range() {
    this.getProperty("range");
  }

  static createRmtContext(rates) {
    return new RmtContext(rates);
  }
  static createBacktestContext() {
    return null; // TODO
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
}

class BackTestContext extends Context {
  // TODO
}
