import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import PositionsTableModel from "../positions/positions-table-model"
import TradingSummaryModel from "../trading-summary/trading-summary-model"

export default class BacktestsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
    this.backtests        = ContainerJS.Inject;

    this.tradingSummariesService  = ContainerJS.Inject;
  }

  postCreate() {
    this.backtestList  = this.viewModelFactory.createBacktestListModel();
    this.miniChart     = this.viewModelFactory.createChart();
    this.chart         = this.viewModelFactory.createChart({
      displayPositionsAndGraphs:true
    });
    this.positionTable =
      this.viewModelFactory.createPositionsTableModel(100, {
        order:     "profit_or_loss",
        direction: "desc"
      });
    this.tradingSummary =
      this.viewModelFactory.createTradingSummaryViewModel();
    this.logViewer = this.viewModelFactory.createLogViewerModel();

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
    } else if (this.activeTab === "logs") {
      this.logViewer.initialize(this.selectedBacktest.id);
      this.logViewer.load();
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
