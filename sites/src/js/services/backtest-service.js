import AbstractService from "./abstract-service"

export default class BacktestService extends AbstractService {

  getAll(ids=null) {
    const url = this.serviceUrl("", ids ? {ids: ids.join(",")} : {});
    return this.xhrManager.xhr( url, "GET" );
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
