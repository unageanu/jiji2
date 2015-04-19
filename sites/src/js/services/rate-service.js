import AbstractService from "./abstract-service"

export default class RateService extends AbstractService {

  getRange() {
    return this.xhrManager.xhr( this.serviceUrl("range"), "GET" );
  }

  getPairs() {
    return this.xhrManager.xhr( this.serviceUrl("pairs"), "GET" );
  }

  getRates( pairName, interval ) {
    return this.xhrManager.xhr(
      this.serviceUrl(pairName +"/"+interval), "GET" );
  }

  endpoint() {
    return "rates";
  }
}
