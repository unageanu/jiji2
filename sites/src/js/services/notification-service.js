import AbstractService from "./abstract-service"

export default class NotificationService extends AbstractService {

  fetch( offset, limit, sortOrder, filterCondition) {
    const url = this.serviceUrl( "", Object.assign({
      offset:        offset,
      limit:         limit,
      order:         sortOrder.order,
      direction:     sortOrder.direction
    }, filterCondition));
    return this.xhrManager.xhr(url, "GET");
  }

  get( notificationId ) {
    return this.xhrManager.xhr(this.serviceUrl( notificationId ), "GET");
  }

  count( filterCondition ) {
    const url = this.serviceUrl( "count", filterCondition);
    return this.xhrManager.xhr(url, "GET");
  }

  markAsRead( notificationId ) {
    const url = this.serviceUrl( notificationId + "/read" );
    return this.xhrManager.xhr(url, "PUT", {
      read: true
    });
  }

  endpoint() {
    return "notifications";
  }
}
