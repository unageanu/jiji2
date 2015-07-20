import TableModel      from "../widgets/table-model"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import Deferred        from "../../utils/deferred"

class Loader {
  constructor( notificationService, backtestId="rmt" ) {
    this.backtestId = backtestId;
    this.notificationService = notificationService;
  }
  load( offset, limit, sortOrder) {
    return this.notificationService.fetchNotifications(
      offset, limit, sortOrder, this.backtestId);
  }
  count() {
    const d = new Deferred();
    this.notificationService.countNotifications(this.backtestId).then(
      (result) => d.resolve(result.count) );
    return d;
  }
}

class NotificationModel {

  constructor(position) {
    for (let i in position) {
      this[i] = position[i];
    }
  }
  get formatedTimestamp() {
    return DateFormatter.format(this.timestamp);
  }

}

export default class NotificationsTableModel extends TableModel {
  constructor( pageSize, defaultSortOrder, notificationService) {
    super( defaultSortOrder, pageSize );
    this.defaultSortOrder = defaultSortOrder;
    this.notificationService = notificationService;
    this.selectedNotification = null;
  }

  initialize(backtestId="rmt") {
    super.initialize(new Loader(this.notificationService, backtestId));
  }

  loadItems() {
    this.selectedNotification = null;
    super.loadItems();
  }

  convertItems(items) {
    return items.map((item) => this.convertItem(item));
  }

  convertItem(item) {
    return new NotificationModel(item);
  }

  set selectedNotification( notification ) {
    this.setProperty("selectedNotification", notification);
  }
  get selectedNotification( ) {
    return this.getProperty("selectedNotification");
  }

}
