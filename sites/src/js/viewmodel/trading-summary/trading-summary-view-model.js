import Observable          from "../../utils/observable"
import TradingSummaryModel from "./trading-summary-model"

export default class TradingSummaryViewModel extends Observable {

  constructor(tradingSummariesService) {
    super();
    this.tradingSummariesService = tradingSummariesService;
    this.registerObservers();
  }

  registerObservers() {
    this.addObserver("propertyChanged", (n, e) => {
      if (e.key === "startTime" || e.key === "backtestId") this.load();
    });
  }

  load() {
    this.tradingSummariesService.get(this.startTime, null, this.backtestId)
    .then((summary) => {
      this.setProperty("summary", new TradingSummaryModel(summary));
    });
  }

  get summary() {
    return this.getProperty("summary");
  }

  set enablePeriodselector(enable) {
    this.setProperty("enablePeriodselector", enable);
  }
  get enablePeriodselector() {
    return this.getProperty("enablePeriodselector");
  }

  set backtestId(backtestId) {
    this.setProperty("backtestId", backtestId);
  }
  get backtestId() {
    return this.getProperty("backtestId");
  }

  set startTime(startTime) {
    this.setProperty("startTime", startTime);
  }
  get startTime() {
    return this.getProperty("startTime");
  }

}
