import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";

export default class Pairs extends Observable {
  constructor() {
    super();
    this.rateService = ContainerJS.Inject;
    this.pairs = [];
  }
  initialize() {
    this.reload();
  }
  reload() {
    this.rateService.getPairs()
      .then( (pairs) => this.pairs = pairs );
  }
  get pairs() {
    return this.getProperty("pairs");
  }
  set pairs(pairs) {
    this.setProperty("pairs", pairs);
  }
}
