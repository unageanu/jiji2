import AbstractService from "./abstract-service"

export default class PairSettingService extends AbstractService {

  getPairs() {
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "GET");
  }
  setPairs(pairs) {
    this.googleAnalytics.sendEvent( "set pairs" );
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "PUT", pairs);
  }

  getAllPairs() {
    const url = this.serviceUrl("/all");
    return this.xhrManager.xhr( url, "GET");
  }

  endpoint() {
    return "settings/pairs";
  }
}
