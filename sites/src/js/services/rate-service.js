import AbstractService from "./abstract-service"

export default class RateService extends AbstractService {

  getRange() {
    return this.xhrManager.xhr( this.serviceUrl("range"), "GET" );
  }

  getPairs() {
    return this.xhrManager.xhr( this.serviceUrl("pairs"), "GET" );
  }

  fetchRates( pairName, interval, start, end ) {
    return this.xhrManager.xhr(
      this.serviceUrl(pairName +"/"+interval), "GET", null, {
        start : start,
        end   : end
      });
  }

  endpoint() {
    return "rates";
  }
}
