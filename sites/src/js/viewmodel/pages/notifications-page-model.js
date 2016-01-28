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
    this.chart = this.viewModelFactory.createChart({
      displaySubGraph: false,
      usePreferencesPairSelector: false
    });

    this.registerObservers();
  }

  registerObservers() {
    this.selection.addObserver("propertyChanged", (n, e) => {
      if (e.key != "selected") return;

      const notification = e.newValue;
      if (notification == null || !notification.isDisplayChart) return;
      this.chart.pairSelector.selectedPair = notification.chartOption.pair;
    });
  }

  initialize( selectedId ) {
    this.notificationsTable.initialize();
    this.notificationsTable.load().then( () => {
      this.selection.selectedId = selectedId;
    });
  }

}
