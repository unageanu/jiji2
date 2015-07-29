import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class HomePageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    const factory =  this.viewModelFactory;
    this.miniChart     = factory.createChart();
    this.notifications = factory.createNotificationsTableModel(5);
    this.positions     = factory.createPositionsTableModel(5);
    this.backtests     = factory.createBacktestListModel();
  }

  initialize() {
    [this.notifications, this.positions, this.backtests].forEach(
      (model) => model.initialize() );
  }
}
