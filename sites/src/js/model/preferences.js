import ContainerJS  from "container-js";
import Observable   from "../utils/observable";

export default class Preferences extends Observable {
  constructor() {
    super({
      preferredPairs: [],
      chartInterval:  "one_minute"
    });
    this.localStorage = ContainerJS.Inject;
    this.pairs        = ContainerJS.Inject;
  }

  initialize() {
    this.restoreState();
    this.addObservers();
  }

  addObservers() {
    this.pairs.addObserver( "propertyChanged", (name, event) => {
      if (event.key !== "pairs") return;
      this.adjustPreferredPairs(event.newValue);
    });
  }

  adjustPreferredPairs(pairs) {
    this.removeIllegalPreferredPairs(pairs);
    this.usingFirstPairsIfPreferredPairIsNotSet(pairs);
  }
  removeIllegalPreferredPairs(pairs) {
    const validPairs = new Set( pairs.map((p) => p.pairName ) );
    this.preferredPairs =  this.preferredPairs
      .filter((p) => validPairs.has(p) );
  }
  usingFirstPairsIfPreferredPairIsNotSet(pairs) {
    if (!this.preferredPair && pairs.length > 0) {
      this.preferredPair = pairs[0].pairName;
    }
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
