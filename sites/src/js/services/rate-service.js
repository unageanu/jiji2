import AbstractService from "./abstract-service"

export default class RateService extends AbstractService {

  getRange() {
    return this.xhrManager.xhr( this.serviceUrl("range"), "GET" );
  }

  getPairs() {
    return this.xhrManager.xhr( this.serviceUrl("pairs"), "GET" );
  }

  fetchRates( name, interval, start, end ) {
    return this.xhrManager.xhr(
      this.serviceUrl(name +"/"+interval), "GET", null, {
        start : start,
        end   : end
      });
  }

  endpoint() {
    return "rates";
  }
}
