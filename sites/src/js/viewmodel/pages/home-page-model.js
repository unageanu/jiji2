import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTTradingSummaryPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.miniChart = this.viewModelFactory.createChart();
  }

}
