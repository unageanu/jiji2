import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTChartPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.chart = this.viewModelFactory.createChart({
      displayPositionsAndGraphs:true
    });
  }

}
