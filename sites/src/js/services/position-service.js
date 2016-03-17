import AbstractService from "./abstract-service"

export default class PositionService extends AbstractService {

  fetchWithin( start, end, backtestId="rmt" ) {
    const url = this.serviceUrl( "", {
      backtestId: backtestId,
      start:      start,
      end:        end
    });
    return this.xhrManager.xhr(url, "GET");
  }

  fetch( offset, limit, sortOrder, backtestId="rmt", status=null ) {
    const url = this.serviceUrl( "", {
      backtestId: backtestId,
      offset:     offset,
      limit:      limit,
      status:     status,
      order:      sortOrder.order,
      direction:  sortOrder.direction
    });
    return this.xhrManager.xhr(url, "GET");
  }

  createCSVDownloadUrl( start, end, sortOrder, backtestId="rmt" ) {
    const url = this.urlResolver.resolveServiceUrl(
      "onetime-tokens/file-download-token");
    return this.xhrManager.xhr(url, "GET").then((result)=>{
      return this.serviceUrl( "download/" + result.token, {
        backtestId: backtestId,
        start:      start,
        end:        end,
        order:      sortOrder.order,
        direction:  sortOrder.direction
      });
    });
  }

  count( backtestId="rmt" ) {
    const url = this.serviceUrl( "count", {
      backtestId: backtestId
    });
    return this.xhrManager.xhr(url, "GET");
  }

  get( positionId ) {
    const url = this.serviceUrl( positionId );
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "positions";
  }
}
