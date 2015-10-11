import Observable          from "../../utils/observable"
import TradingSummaryModel from "./trading-summary-model"


export default class TradingSummaryViewModel extends Observable {

  constructor(tradingSummariesService, timeSource) {
    super();
    this.tradingSummariesService = tradingSummariesService;
    this.timeSource = timeSource;

    this.registerObservers();
    this.setAvailableAggregationPeriods();
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

  setAvailableAggregationPeriods() {
    const now = this.timeSource.now;
    const day = 1000*60*60*24;
    this.availableAggregationPeriods = [
      { id: "week",         text: "直近の1週間", time: new Date(now-7*day)},
      { id: "one_month",    text: "直近の30日",  time: new Date(now-30*day)},
      { id: "three_months", text: "直近の90日",  time: new Date(now-90*day)},
      { id: "one_year",     text: "直近の1年",   time: new Date(now-365*day)}
    ];
  }

  get summary() {
    return this.getProperty("summary");
  }

  set enablePeriodSelector(enable) {
    this.setProperty("enablePeriodSelector", enable);
  }
  get enablePeriodSelector() {
    return this.getProperty("enablePeriodSelector");
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

  set availableAggregationPeriods(periods) {
    this.setProperty("availableAggregationPeriods", periods);
  }
  get availableAggregationPeriods() {
    return this.getProperty("availableAggregationPeriods");
  }

}
