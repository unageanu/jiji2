import ContainerJS  from "container-js";
import Observable   from "../utils/observable";

export default class Preferences extends Observable {
  constructor() {
    super({
      preferredPairs: [],
      chartInterval:  "one_minute"
    });
    this.localStorage = ContainerJS.Inject;
  }

  restoreState() {
    const data = this.localStorage.get("preferences") || {};

    this.setProperty("preferredPairs", data.preferredPairs || []);
    this.setProperty("chartInterval",  data.chartInterval || "one_minute");
  }

  get preferredPair() {
    return this.preferredPairs[0];
  }
  set preferredPair(pairName) {
    let preferredPairs =
      this.preferredPairs.filter((item) => item !== pairName );
    preferredPairs.unshift(pairName);
    this.setProperty("preferredPairs", preferredPairs);
    this.saveState();
  }
  get preferredPairs() {
    return this.getProperty("preferredPairs");
  }
  set preferredPairs(pairs) {
    this.setProperty("preferredPairs", pairs);
    this.saveState();
  }
  get chartInterval() {
    return this.getProperty("chartInterval");
  }

  set chartInterval(interval) {
    this.setProperty("chartInterval", interval);
    this.saveState();
  }

  saveState() {
    this.localStorage.set("preferences", {
      preferredPairs : this.preferredPairs,
      chartInterval :  this.chartInterval
    });
  }
}
