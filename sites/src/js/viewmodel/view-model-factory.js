import ContainerJS  from "container-js";
import Chart       from "./chart/chart";

export default class ViewModelFactory {

  constructor() {
    this.rates           = ContainerJS.Inject;
    this.preferences     = ContainerJS.Inject;
    this.rateService     = ContainerJS.Inject;
    this.positionService = ContainerJS.Inject;
  }
  createChart(displayPositions=false, backtestId=null) {
    return new Chart( this.rates, this.preferences,
      this.positionService, displayPositions, backtestId );
  }

}
