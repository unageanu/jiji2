import AbstractService from "./abstract-service"

export default class TradingSummariesService extends AbstractService {

  get( start=null, end=null, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "trading-summaries";
  }
}
