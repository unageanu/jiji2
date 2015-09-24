import TableModel        from "../widgets/table-model"
import NumberFormatter   from "../utils/number-formatter"
import DateFormatter     from "../utils/date-formatter"
import Deferred          from "../../utils/deferred"
import Observable        from "../../utils/observable"
import NotificationModel from "./notification-model"

export default class NotificationSelectionModel extends Observable {

  constructor( notificationService,
    actionService, eventQueue, urlResolver) {
    super();
    this.notificationService = notificationService;
    this.actionService = actionService;
    this.urlResolver = urlResolver;
    this.eventQueue = eventQueue;

    this.selectedNotificationId = null;
    this.selectedNotification   = null;
  }

  attach(tableModel) {
    this.tableModel = tableModel;
    this.tableModel.addObserver("beforeLoadItems", () => {
      this.selectedNotification = null;
      this.selectedNotificationId = null;
    });
  }

  convertItem(item) {
    return new NotificationModel(item, this.urlResolver);
  }

  findNotificationFromItems(notificationId) {
    if (!this.tableModel || !this.tableModel.items) return false;
    return this.selectedNotification =
        this.tableModel.items.find((n) => n.id == notificationId);
  }
  loadNotification(notificationId) {
    this.selectedNotification = null;
    this.notificationService.get(notificationId).then( (notification)=> {
      this.selectedNotification = this.convertItem(notification);
    });
  }

  markAsRead(notification) {
    notification.readAt = new Date();
    if (this.tableModel) {
      const table = this.tableModel;
      table.setProperty("items", table.items, () => false );
      table.notRead = table.notRead > 0 ? table.notRead-1 : 0;
    }
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
}
