import TableModel      from "../widgets/table-model"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import Deferred        from "../../utils/deferred"

const defaultFilterConditions = [
  { id: "all", text:"すべて",        condition: {backtestId: null} },
  { id: "rmt", text:"リアルトレード", condition: {backtestId: "rmt"} }
];

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
      (result) => d.resolve(result) );
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
  constructor( pageSize, defaultSortOrder, notificationService,
    actionService, backtests, eventQueue) {
    super( defaultSortOrder, pageSize );
    this.backtests = backtests;
    this.defaultSortOrder = defaultSortOrder;
    this.notificationService = notificationService;
    this.actionService = actionService;
    this.eventQueue = eventQueue;
    this.selectedNotification = null;
    this.availableFilterConditions = defaultFilterConditions;
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
    const backtestConditions = this.backtests.tests.map((test) => {
      return {
        id: test.id,
        text: test.name,
        condition: {backtestId: test.id }
      };
    });
    return defaultFilterConditions.concat(backtestConditions);
  }

  processCount(count) {
    this.notRead = count.notRead;
  }

  markAsRead(notification) {
    notification.readAt = new Date();
    this.setProperty("items", this.items);
    this.notRead = this.notRead > 0 ? this.notRead-1 : 0;
    this.notificationService.markAsRead( notification.id );
  }

  executeAction( notification, action ) {
    this.actionService.post(notification.backtestId,
      notification.agentId, action).then((result) => {
      this.eventQueue.push(
        this.createResponseMessage(result, notification, action));
    }, (error)  => {
      error.preventDefault = true;
      this.eventQueue.push(this.createErrorMessage(error, notification));
    });
  }
  createResponseMessage(result, notification, action) {
    return {
      type: "info",
      message: notification.agentName + " : "
        + (result.message || "アクション \"" + action + "\" を実行しました")
    };
  }
  createErrorMessage(error, notification) {
    return {
      type: "error",
      message: notification.agentName
        + " : アクション実行時にエラーが発生しました。"
        + "ログを確認してください。"
    };
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

  set notRead(notRead) {
    this.setProperty("notRead", notRead);
  }
  get notRead() {
    return this.getProperty("notRead");
  }
}
