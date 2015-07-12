import ContainerJS             from "container-js"
import Chart                   from "./chart/chart"
import PositionsTableModel     from "./positions/positions-table-model"
import TradingSummaryViewModel from "./trading-summary/trading-summary-view-model"

export default class ViewModelFactory {

  constructor() {
    this.rates                   = ContainerJS.Inject;
    this.preferences             = ContainerJS.Inject;
    this.rateService             = ContainerJS.Inject;
    this.positionService         = ContainerJS.Inject;
    this.graphService            = ContainerJS.Inject;
    this.tradingSummariesService = ContainerJS.Inject;
  }
  createChart(config={displayPositionsAndGraphs:false}) {
    return new Chart( config, this );
  }
  createPositionsTableModel(pageSize=100, sortOrder={}) {
    return new PositionsTableModel(
      pageSize, sortOrder, this.positionService );
  }
  createTradingSummaryViewModel(enablePeriodselector=false) {
    const model = new TradingSummaryViewModel( this.tradingSummariesService );
    model.enablePeriodselector = enablePeriodselector;
    return model;
  }
}
