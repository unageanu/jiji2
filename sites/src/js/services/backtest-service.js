import AbstractService from "./abstract-service"

export default class BacktestService extends AbstractService {

  getAll() {
    return this.xhrManager.xhr( this.serviceUrl(), "GET");
  }
  getRunnings() {
    return this.xhrManager.xhr( this.serviceUrl(null, {
      status : "runnings"
    }), "GET");
  }

  get(id) {
    return this.xhrManager.xhr( this.serviceUrl(id), "GET");
  }

  register( testConfig ) {
    return this.xhrManager.xhr( this.serviceUrl(), "POST", testConfig);
  }
  remove( id ) {
    return this.xhrManager.xhr( this.serviceUrl(id), "DELETE");
  }

  endpoint() {
    return "backtests";
  }
}
