import AbstractService from "./abstract-service"

export default class BacktestService extends AbstractService {

  getAll(ids=null, background=false) {
    const url = this.serviceUrl("", ids ? {ids: ids.join(",")} : {});
    return this.xhrManager.xhr( url, "GET", null, {isBackground:background});
  }

  get(id) {
    return this.xhrManager.xhr( this.serviceUrl(id), "GET");
  }

  getAgentSettings(id) {
    return this.xhrManager.xhr( this.serviceUrl(id+"/agent-settings"), "GET");
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