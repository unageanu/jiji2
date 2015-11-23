import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class HomePageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;

    this.visibleTradingSummary = true;
    this.notificationCount = 5;
    this.positionCount = 5;
  }

  postCreate() {
    const factory      =  this.viewModelFactory;
    this.miniChart     = factory.createChart({
      displaySubGraph: false
    });
    this.notifications = factory
      .createNotificationsTableModel(this.notificationCount);
    this.positions     = factory
      .createPositionsTableModel(this.positionCount, {
        order:"entered_at", direction:"desc"
      });
    this.backtests     = factory.createBacktestListModel();
    this.accounts      = factory.createAccountViewModel();

    if (this.visibleTradingSummary) {
      this.tradingSummary =
        this.viewModelFactory.createTradingSummaryViewModel(false);
    }
  }

  initialize() {
    [this.notifications, this.positions, this.accounts].forEach(
      (model) => model.initialize() );

    this.notifications.filterCondition = {
      status: "not_read"
    };
    this.notifications.load();
    this.positions.load();

    if (this.visibleTradingSummary) {
      this.tradingSummary.startTime =
        new Date(new Date().getTime()-7*1000*60*60*24);
    }
  }
}
