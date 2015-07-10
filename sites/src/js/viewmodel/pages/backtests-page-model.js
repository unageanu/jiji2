import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import BacktestListModel   from "../backtests/backtest-list-model"
import PositionsTableModel from "../positions/positions-table-model"
import TradingSummaryModel from "../trading-summary/trading-summary-model"

export default class BacktestsPageModel extends Observable {

  constructor() {
    super();
    this.backtests = ContainerJS.Inject;
    this.viewModelFactory = ContainerJS.Inject;

    this.tradingSummariesService  = ContainerJS.Inject;
  }

  postCreate() {
    this.backtestListModel  = new BacktestListModel(this.backtests);
    this.miniChart = this.viewModelFactory.createChart();
    this.chart     = this.viewModelFactory.createChart({
      displayPositionsAndGraphs:true
    });
    this.positionTable =
      this.viewModelFactory.createPositionsTableModel(null, 100, {
        order:     "profit_or_loss",
        direction: "desc"
      });
    this.tradingSummary =
      this.viewModelFactory.createTradingSummaryViewModel();

    this.addObserver("propertyChanged", (n, e) => {
      if (e.key === "activeTab") this.onTabChanged();
      if (e.key === "selectedBacktest") this.onBacktestChanged();
    });
  }

  initialize( ) {
    this.selectedBacktestId = null;
    this.selectedBacktest   = null;
    this.activeTab          = null;

    this.backtests.initialize().then(
      () => this.onBacktestLoaded());
  }

  onBacktestLoaded() {
    this.selectedBacktest = this.backtests.get(this.selectedBacktestId);
  }

  onTabChanged() {
    this.initializeActiveTabData();
  }
  onBacktestChanged() {
    if (!this.selectedBacktest) return;
    this.positionTable.initialize( this.selectedBacktest.id );
    this.initializeActiveTabData();
  }

  initializeActiveTabData() {
    if (this.activeTab === "trades") {
      this.positionTable.load();
    } else if (this.activeTab === "report") {
      this.tradingSummary.backtestId = this.selectedBacktest.id;
    } else if (this.activeTab === "chart") {
      this.chart.backtest =this.selectedBacktest;
    } else {
      this.miniChart.backtest =this.selectedBacktest;
    }
  }

  get selectedBacktestId() {
    return this.getProperty("selectedBacktestId");
  }
  set selectedBacktestId(id) {
    this.setProperty("selectedBacktestId", id);
    this.backtests.initialize().then(
      () => this.onBacktestLoaded());
  }

  get selectedBacktest() {
    return this.getProperty("selectedBacktest");
  }
  set selectedBacktest(backtest) {
    this.setProperty("selectedBacktest", backtest);
  }

  get activeTab() {
    return this.getProperty("activeTab");
  }
  set activeTab(id) {
    this.setProperty("activeTab", id);
  }


  get tradingSummary() {
    return this.getProperty("tradingSummary");
  }
  set tradingSummary(summary) {
    this.setProperty("tradingSummary", summary);
  }
}
