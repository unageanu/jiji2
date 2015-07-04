import AbstractService from "./abstract-service"

export default class PositionService extends AbstractService {

  fetchPositionsWithin( start, end, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      start : start,
      end   : end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  fetchPositions( offset, limit, sortOrder, backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId, {
      offset:    offset,
      limit:     limit,
      order:     sortOrder.order,
      direction: sortOrder.direction
    });
    return this.xhrManager.xhr(url, "GET");
  }

  countPositions( backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId+"/count");
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "positions";
  }
}
