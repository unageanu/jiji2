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

  setPair(pairName) {
    this.preferredPairs =
      this.preferredPairs.filter((item) => item !== pairName );
    this.preferredPairs.unshift(pairName);

    this.saveState();
    this.fire("changed", {key:"pair", value:this.preferredPairs});
  }
  setChartInterval(interval) {
    this.chartInterval = interval;
    this.saveState();
    this.fire("changed", {key:"chartInterval", value:this.chartInterval});
  }

  saveState() {
    this.localStorage.set("preferences", {
      preferredPairs : this.preferredPairs,
      chartInterval : this.chartInterval
    });
  }
}
