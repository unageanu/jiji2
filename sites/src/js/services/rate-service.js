import AbstractService from "./abstract-service"

export default class RateService extends AbstractService {

  getRange() {
    return this.xhrManager.xhr( this.serviceUrl("range"), "GET" );
  }

  getPairs() {
    return this.xhrManager.xhr( this.serviceUrl("pairs"), "GET" );
  }

  fetchRates( name, interval, start, end ) {
    const url = this.serviceUrl(name +"/"+interval, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "rates";
  }
}
