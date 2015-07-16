import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import BacktestList       from "../backtests/backtest-list"
import MiniChartView      from "../chart/mini-chart-view"
import ChartView          from "../chart/chart-view"
import PositionsTable     from "../positions/positions-table"
import TradingSummaryView from "../trading-summary/trading-summary-view"
import LogViewer          from "../logs/log-viewer"

const Tabs  = MUI.Tabs;
const Tab   = MUI.Tab;

export default class BacktestsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      selectedBacktestId: null,
      selectedBacktest: null,
      activeTab: null
    };
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model);

    model.initialize();
    model.selectedBacktestId = this.props.params.id;
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  componentWillReceiveProps(nextProps) {
    this.model().selectedBacktestId = nextProps.params.id;
  }

  render() {
    const model      = this.model();
    const tab        = this.createTabs();
    const tabContent = this.createTabContent();
    return (
      <div className="backtests">
        <BacktestList
          selectedId={this.state.selectedBacktestId}
          model={model.backtestListModel} />
        <div className="details">
          {tab}
          {tabContent}
        </div>
      </div>
    );
  }

  createTabs() {
    if (!this.state.selectedBacktest) return null;

    const base = "/backtests/list/" + this.state.selectedBacktest.id;
    return <Tabs
      onChange={this.onTabChanged.bind(this)}
      initialSelectedIndex={0}>
      <Tab label="ホーム"   name=""></Tab>
      <Tab label="レポート" name="report"></Tab>
      <Tab label="チャート" name="chart"></Tab>
      <Tab label="取引一覧" name="trades"></Tab>
      <Tab label="ログ"    name="logs"></Tab>
    </Tabs>;
  }

  createTabContent() {
    if (!this.state.selectedBacktest) return null;

    if ( this.state.activeTab === "chart" ) {
      return <ChartView
          model={this.model().chart}
          size={{w:600, h:500, profitAreaHeight:100, graphAreaHeight:100}}
      />;
    } else if ( this.state.activeTab === "report" ) {
      return <TradingSummaryView model={this.model().tradingSummary} />;
    } else if ( this.state.activeTab === "trades" ) {
      return <PositionsTable model={this.model().positionTable} />;
    } else if ( this.state.activeTab === "logs" ) {
        return <LogViewer model={this.model().logViewer} />;
    } else {
      return <MiniChartView
          model={this.model().miniChart}
          size={{w:600, h:500}}
        />;
    }
  }

  onTabChanged(tabIndex, tab) {
    this.model().activeTab = tab.props.name;
  }

  model() {
    return this.context.application.backtestsPageModel;
  }
}
BacktestsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
