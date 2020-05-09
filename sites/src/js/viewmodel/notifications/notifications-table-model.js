import TableModel        from "../widgets/table-model"
import NumberFormatter   from "../utils/number-formatter"
import DateFormatter     from "../utils/date-formatter"
import Deferred          from "../../utils/deferred"
import NotificationModel from "./notification-model"

const defaultFilterConditions = [
  { id: "all", condition: {backtestId: null} },
  { id: "rmt", condition: {backtestId: "rmt"} }
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

export default class NotificationsTableModel extends TableModel {
  constructor( pageSize, defaultSortOrder,
    notificationService, backtests, urlResolver, pushNotifier) {
    super( defaultSortOrder, pageSize );
    this.backtests = backtests;
    this.defaultSortOrder = defaultSortOrder;
    this.notificationService = notificationService;
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
