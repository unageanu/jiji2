import AbstractService from "./abstract-service"

export default class PositionService extends AbstractService {

  fetchPositions( start, end, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "positions";
  }
}
