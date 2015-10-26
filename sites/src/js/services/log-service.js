import AbstractService from "./abstract-service"

export default class LogService extends AbstractService {

  get( index, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      offset:    index
    });
    return this.xhrManager.xhr(url, "GET");
  }

  count( backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId+"/count");
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "logs";
  }
}
