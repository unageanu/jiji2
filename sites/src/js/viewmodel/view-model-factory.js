import ContainerJS         from "container-js"
import Chart               from "./chart/chart"
import PositionsTableModel from "./positions/positions-table-model"

export default class ViewModelFactory {

  constructor() {
    this.rates           = ContainerJS.Inject;
    this.preferences     = ContainerJS.Inject;
    this.rateService     = ContainerJS.Inject;
    this.positionService = ContainerJS.Inject;
    this.graphService    = ContainerJS.Inject;
  }
  createChart(backtest=null, config={displayPositionsAndGraphs:false}) {
    return new Chart( backtest, config, this );
  }
  createPositionsTableModel(backtestId=null, pageSize=100, sortOrder={}) {
    return new PositionsTableModel(
      backtestId, pageSize, sortOrder, this.positionService );
  }
}
