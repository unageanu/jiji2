import AbstractService from "./abstract-service"

export default class BacktestService extends AbstractService {

  getAll(ids=null) {
    return this.xhrManager.xhr( this.serviceUrl(), "GET",
      null, ids ? {ids: ids.join(",")} : null);
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
