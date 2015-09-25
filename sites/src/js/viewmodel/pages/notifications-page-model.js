import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class NotificationsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.notificationsTable =
      this.viewModelFactory.createNotificationsTableModel(10);
    this.selection =
        this.viewModelFactory.createNotificationSelectionModel();
    this.selection.attach(this.notificationsTable);
  }

  initialize( selectedId ) {
    this.notificationsTable.initialize();
    this.notificationsTable.load().then( () => {
      this.selection.selectedId = selectedId;
    });
  }

}
