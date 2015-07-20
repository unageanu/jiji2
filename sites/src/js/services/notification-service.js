import AbstractService from "./abstract-service"

export default class NotificationService extends AbstractService {

  fetchNotifications( offset, limit, sortOrder, backtestId="rmt") {
    const url = this.serviceUrl( backtestId, {
      offset:    offset,
      limit:     limit,
      order:     sortOrder.order,
      direction: sortOrder.direction
    });
    return this.xhrManager.xhr(url, "GET");
  }

  countNotifications( backtestId="rmt" ) {
    const url = this.serviceUrl( backtestId+"/count");
    return this.xhrManager.xhr(url, "GET");
  }

  endpoint() {
    return "notifications";
  }
}
