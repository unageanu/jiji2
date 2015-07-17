import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";
import Deferred     from "../../utils/deferred";

export default class Pairs extends Observable {
  constructor() {
    super();
    this.rateService = ContainerJS.Inject;
    this.pairs = [];
  }

  initialize() {
    if (!this.isInitialied()) {
      this.initializedDeferred = this.reload();
    }
    return this.initializedDeferred;
  }

  isInitialied() {
    if (!this.initializedDeferred) return false;
    if (this.initializedDeferred.rejected()) return false;
    return true;
  }

  reload() {
    const d = this.rateService.getPairs();
    d.done( (pairs) => this.pairs = pairs );
    return d;
  }
  get pairs() {
    return this.getProperty("pairs");
  }
  set pairs(pairs) {
    this.setProperty("pairs", pairs);
  }
}
