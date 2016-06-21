import React                  from "react"

import AbstractComponent      from "../widgets/abstract-component"
import MiniChartView          from "../chart/mini-chart-view"
import ChartView              from "../chart/chart-view"
import PositionsTable         from "../positions/positions-table"
import PositionDetailsView    from "../positions/position-details-view"
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
          size={this.calculateChartSize()}
      />;
    } else if ( this.state.activeTab === "report" ) {
      return <TradingSummaryView
        model={this.model().tradingSummary}
        graphSize={150} />;
    } else if ( this.state.activeTab === "trades" ) {
      return <div className="positions">
        <PositionDetailsView model={this.model().selection} />
        <PositionsTable
          model={this.model().positionTable}
          downloadModel={this.model().positionDownloader}
          selectionModel={this.model().selection}
          onItemTapped={(ev,item) => this.model().selection.selectedId = item.id } />
      </div>;
    } else if ( this.state.activeTab === "logs" ) {
      return <LogViewer model={this.model().logViewer} />;
    } else {
      return <BacktestPropertiesView model={this.model()} />;
    }
  }


  calculateChartSize() {
    const windowSize = this.context.windowResizeManager.windowSize;
    return {
      w: windowSize.w - 288 - 16*5 - 280,
      h: windowSize.h - 100 - 16*4 - 250 - 20,
      profitAreaHeight:80,
      graphAreaHeight:80
    };
  }

  model() {
    return this.props.model;
  }
}
BacktestDetailsPanel.propTypes = {
  model: React.PropTypes.object
};
BacktestDetailsPanel.contextTypes = {
  windowResizeManager: React.PropTypes.object.isRequired,
};
