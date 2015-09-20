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
    return this.notificationService.fetch(
      offset, limit, sortOrder, filterCondition);
  }
  count(filterCondition) {
    return this.notificationService.count(filterCondition);
  }
}

class NotificationModel {

  constructor(position, urlResolver) {
    for (let i in position) {
      this[i] = position[i];
    }
    this.urlResolver = urlResolver;
  }
  get formatedTimestamp() {
    return DateFormatter.format(this.timestamp);
  }
  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }
}

export default class NotificationsTableModel extends TableModel {
  constructor( pageSize, defaultSortOrder, notificationService,
    actionService, backtests, eventQueue, urlResolver, pushNotifier) {
    super( defaultSortOrder, pageSize );
    this.backtests = backtests;
    this.defaultSortOrder = defaultSortOrder;
    this.notificationService = notificationService;
    this.actionService = actionService;
    this.eventQueue = eventQueue;
    this.selectedNotification = null;
    this.availableFilterConditions = defaultFilterConditions;
    this.urlResolver = urlResolver;
    this.pushNotifier = pushNotifier;

    this.registerNotificationReceivedEventObserver(pushNotifier);
  }

  registerNotificationReceivedEventObserver(pushNotifier) {
    pushNotifier.addObserver("notificationReceived", (n, event) => {
      const backtestId = event.data.additionalData.backtestId;
      if (this.offset != 0) return;
      if (this.filterCondition.backtestId == null
        || backtestId == this.filterCondition.backtestId
        || (backtestId == null && this.filterCondition.backtestId == "rmt")) {
        this.load();
      }
    });
  }

  initialize() {
    super.initialize(new Loader(this.notificationService));
    this.filterCondition = {backtestId: null};
    this.backtests.initialize().then(() =>
      this.availableFilterConditions = this.createAvailableFilterConditions());
  }

  loadItems() {
    this.selectedNotificationId = null;
    this.selectedNotification = null;
    super.loadItems();
  }

  convertItems(items) {
    return items.map((item) => this.convertItem(item));
  }

  convertItem(item) {
    return new NotificationModel(item, this.urlResolver);
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
      notification.agent.id, action).then((result) => {
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
      message: notification.agent.name + " : "
        + (result.message || "アクション \"" + action + "\" を実行しました")
    };
  }
  createErrorMessage(error, notification) {
    return {
      type: "error",
      message: notification.agent.name
        + " : アクション実行時にエラーが発生しました。"
        + "ログを確認してください。"
    };
  }

  findNotificationFromItems(notificationId) {
    return this.selectedNotification
      = this.items.find((n) => n.id == notificationId);
  }
  loadNotification(notificationId) {
    this.selectedNotification = null;
    this.notificationService.get(notificationId).then( (notification)=> {
      this.selectedNotification = this.convertItem(notification);
    });
  }

  set selectedNotificationId( notificationId ) {
    this.setProperty("selectedNotificationId", notificationId);
    if (notificationId == null) return;
    this.findNotificationFromItems(notificationId)
    || this.loadNotification(notificationId);
  }
  get selectedNotificationId( ) {
    return this.getProperty("selectedNotificationId");
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
