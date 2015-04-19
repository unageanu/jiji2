import ContainerJS  from "container-js";
import Observable   from "../utils/observable";

export default class Preferences extends Observable {
  constructor() {
    this.localStorage = ContainerJS.Inject;
  }

  restoreState() {
    const data = this.localStorage.get("preferences") || {};

    this.preferredPairs = data.preferredPairs || [];
    this.chartInterval  = data.chartInterval || "one_minute";
  }

  get preferredPair() {
    return this.preferredPairs[0];
  }
  set preferredPair(pairName) {
    this.preferredPairs =
      this.preferredPairs.filter((item) => item !== pairName );
    this.preferredPairs.unshift(pairName);

    this.saveState();
    this.fire("changed", {key:"preferredPairs", value:this.preferredPairs});
  }

  get chartInterval() {
    return this._chartInterval;
  }

  set chartInterval(interval) {
    this._chartInterval = interval;
    this.saveState();
    this.fire("changed", {key:"chartInterval", value:this._chartInterval});
  }

  saveState() {
    this.localStorage.set("preferences", {
      preferredPairs : this.preferredPairs,
      chartInterval :  this._chartInterval
    });
  }
}
