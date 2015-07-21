import TableModel      from "../widgets/table-model"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import Deferred        from "../../utils/deferred"

class Loader {
  constructor( notificationService ) {
    this.notificationService = notificationService;
  }
  load( offset, limit, sortOrder, filterCondition) {
    return this.notificationService.fetchNotifications(
      offset, limit, sortOrder, this.extractBacktestId(filterCondition));
  }
  count(filterCondition) {
    const d = new Deferred();
    const backtestId = this.extractBacktestId(filterCondition);
    this.notificationService.countNotifications(backtestId).then(
      (result) => d.resolve(result.count) );
    return d;
  }
  extractBacktestId(filterCondition) {
    return (filterCondition||{}).backtestId;
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
  constructor( pageSize, defaultSortOrder, notificationService, backtests) {
    super( defaultSortOrder, pageSize );
    this.backtests = backtests;
    this.defaultSortOrder = defaultSortOrder;
    this.notificationService = notificationService;
    this.selectedNotification = null;
  }

  initialize() {
    super.initialize(new Loader(this.notificationService));
    this.filterCondition = {backtestId: null};
    this.backtests.initialize().then(() =>
      this.availableFilterConditions = this.createAvailableFilterConditions());
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

  createAvailableFilterConditions() {
    const conditions = [
      { id: "all", text:"すべて",        condition: {backtestId: null} },
      { id: "rmt", text:"リアルトレード", condition: {backtestId: "rmt"} }
    ];
    this.backtests.tests.forEach((test) => {
      conditions.push({
        id: test.id,
        text: test.name,
        condition: {backtestId: test.id }
      });
    });
    return conditions;
  }

  markAsRead(notification) {
    notification.readAt = new Date();
    this.setProperty("items", this.items);
    this.notificationService.markAsRead( notification.id );
  }

  set selectedNotification( notification ) {
    this.setProperty("selectedNotification", notification);
    if (notification && !notification.readAt) {
      this.markAsRead(notification);
    }
  }
  get selectedNotification( ) {
    return this.getProperty("selectedNotification");
  }

  set availableFilterConditions( availableFilterConditions ) {
    this.setProperty("availableFilterConditions", availableFilterConditions);
  }
  get availableFilterConditions( ) {
    return this.getProperty("availableFilterConditions");
  }

}
