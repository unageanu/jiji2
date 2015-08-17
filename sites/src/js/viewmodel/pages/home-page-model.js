import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class HomePageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    const factory      =  this.viewModelFactory;
    this.miniChart     = factory.createChart({
      displayPositionsAndGraphs: true
    });
    this.notifications = factory.createNotificationsTableModel(5);
    this.positions     = factory.createPositionsTableModel(5);
    this.backtests     = factory.createBacktestListModel();
    this.accounts      = factory.createAccountViewModel();
    this.tradingSummary =
      this.viewModelFactory.createTradingSummaryViewModel(false);
  }

  initialize() {
    [this.notifications, this.positions, this.accounts].forEach(
      (model) => model.initialize() );
    this.tradingSummary.startTime =
      new Date(new Date().getTime()-7*1000*60*60*24);
  }
}
