import AbstractService from "./abstract-service"

export default class LogService extends AbstractService {

  get( index, direction="asc", backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      offset:    index,
      direction: direction
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
