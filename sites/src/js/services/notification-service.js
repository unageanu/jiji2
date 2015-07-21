import AbstractService from "./abstract-service"

export default class NotificationService extends AbstractService {

  fetchNotifications( offset, limit, sortOrder, backtestId) {
    const url = this.serviceUrl( "", {
      offset:    offset,
      limit:     limit,
      order:     sortOrder.order,
      direction: sortOrder.direction,
      backtestId: backtestId
    });
    return this.xhrManager.xhr(url, "GET");
  }

  countNotifications( backtestId ) {
    const url = this.serviceUrl( "count", {
      backtestId: backtestId
    });
    return this.xhrManager.xhr(url, "GET");
  }

  markAsRead( notificationId ) {
    const url = this.serviceUrl( notificationId);
    return this.xhrManager.xhr(url, "PUT", {
      read: true
    });
  }

  endpoint() {
    return "notifications";
  }
}
