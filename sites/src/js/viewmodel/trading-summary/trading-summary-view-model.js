import Observable          from "../../utils/observable"
import TradingSummaryModel from "./trading-summary-model"

export default class TradingSummaryViewModel extends Observable {

  constructor(tradingSummariesService) {
    super();
    this.tradingSummariesService = tradingSummariesService;
  }

  load(backtestId) {
    this.tradingSummariesService.get(null, null, backtestId).then((summary) => {
      this.setProperty("summary", new TradingSummaryModel(summary));
    });
  }

  get summary() {
    return this.getProperty("summary");
  }

}
