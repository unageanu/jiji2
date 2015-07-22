import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class NotificationsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.notificationsTable =
      this.viewModelFactory.createNotificationsTableModel(100);
    this.notificationsTable.initialize();
  }

  initialize( ) {
    this.notificationsTable.load();
  }

}
