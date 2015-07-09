import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import BacktestListModel   from "../backtests/backtest-list-model"
import PositionsTableModel from "../positions/positions-table-model"
import TradingSummaryModel from "../trading-summary/trading-summary-model"

export default class HomePageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.tradingSummary =
      this.viewModelFactory.createTradingSummaryViewModel();
  }

}
