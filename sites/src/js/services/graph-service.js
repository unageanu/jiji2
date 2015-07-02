import AbstractService from "./abstract-service"

export default class GraphService extends AbstractService {

  fetchGraphs( start, end, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  fetchGraphData( start, end, interval, backtestId="rmt" ) {
    const url = this.serviceUrl( "data/" + backtestId + "/" + interval, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "graph";
  }
}
