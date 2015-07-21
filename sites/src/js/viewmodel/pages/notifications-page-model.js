import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class NotificationsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.notificatiosTable =
      this.viewModelFactory.createNotificationsTableModel(100);
    this.notificatiosTable.initialize();
  }

  initialize( ) {
    this.notificatiosTable.load();
  }

}
