import ContainerJS        from "container-js"
import Observable         from "../../utils/observable"
import BacktestListModel  from "../backtests/backtest-list-model"

export default class BacktestsPageModel extends Observable {

  constructor() {
    super();
    this.backtests = ContainerJS.Inject;
  }

  postCreate() {
    this.backtestListModel = new BacktestListModel(this.backtests);
  }

  initialize( param ) {
    this.selectedBacktestId = param.id;
    this.selectedBacktest   = null;

    this.backtests.initialize().then(
      () => this.onBacktestLoaded());
  }

  onBacktestLoaded() {
    this.selectedBacktest = this.backtests.get(this.selectedBacktestId);
  }

  get selectedBacktestId() {
    return this.getProperty("selectedBacktestId");
  }
  set selectedBacktestId(id) {
    this.setProperty("selectedBacktestId", id);
  }

  get selectedBacktest() {
    return this.getProperty("selectedBacktest");
  }
  set selectedBacktest(backtest) {
    this.setProperty("selectedBacktest", backtest);
  }
}
