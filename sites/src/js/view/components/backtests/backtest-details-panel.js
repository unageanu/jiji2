import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"
import MiniChartView          from "../chart/mini-chart-view"
import ChartView              from "../chart/chart-view"
import PositionsTable         from "../positions/positions-table"
import TradingSummaryView     from "../trading-summary/trading-summary-view"
import LogViewer              from "../logs/log-viewer"
import BacktestDetailsTab     from "../backtests/backtest-details-tab"
import BacktestPropertiesView from "./backtest-properties-view"

const keys = new Set([
  "selectedBacktest", "activeTab"
]);

export default class BacktestDetailsPanel extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    if (!this.state.selectedBacktest) return null;

    return (
      <div className="backtest-details-panel">
        <BacktestDetailsTab model={this.model()} />
        {this.createTabContent()}
      </div>
    );
  }

  createTabContent() {
    if ( this.state.activeTab === "chart" ) {
      return <ChartView
          model={this.model().chart}
          size={{w:600, h:500, profitAreaHeight:100, graphAreaHeight:100}}
      />;
    } else if ( this.state.activeTab === "report" ) {
      return <TradingSummaryView
        model={this.model().tradingSummary}
        graphSize={150} />;
    } else if ( this.state.activeTab === "trades" ) {
      return <PositionsTable
        model={this.model().positionTable}
        selectionModel={this.model().selection} />;
    } else if ( this.state.activeTab === "logs" ) {
      return <LogViewer model={this.model().logViewer} />;
    } else {
      return <BacktestPropertiesView model={this.model()} />;
    }
  }

  model() {
    return this.props.model;
  }
}
BacktestDetailsTab.propTypes = {
  model: React.PropTypes.object
};
