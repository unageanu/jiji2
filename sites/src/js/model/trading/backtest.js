import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"

export default class Backtest extends Observable {

  constructor(info) {
    super();

    for (let i in info) {
      this[i] = info[i];
    }
  }

  injectServices(graphService, positionService, backtestService) {
    this.graphService    = graphService;
    this.positionService = positionService;
    this.backtestService = backtestService;
  }

  isFinished() {
    return this.status === "finished"
        || this.status === "cancelled"
        || this.status === "error";
  }
}
