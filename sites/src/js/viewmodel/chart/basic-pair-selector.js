import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"

export default class BasicPairSelector extends Observable {

  constructor(pairs, defaultSelectedPair) {
    super();
    this.pairs = pairs;
    this.registerObservers();

    this.setProperty("availablePairs", pairs.pairs);
    this.selectedPair = defaultSelectedPair;
  }

  registerObservers() {
    this.pairs.addObserver("propertyChanged", (n, e) => {
      if (e.key != "pairs") return;
      this.onPairChanged(n, e);
    }, this);
  }

  unregisterObservers() {
    this.pairs.removeAllObservers(this);
  }

  onPairChanged(n, e) {
    this.setProperty("availablePairs", e.newValue);
    this.selectedPair = this.getProperty("originalSelectedPair");
  }

  get availablePairs() {
    return this.getProperty("availablePairs");
  }

  get selectedPair() {
    return this.getProperty("selectedPair");
  }
  set selectedPair(selectedPair) {
    this.setProperty("originalSelectedPair", selectedPair);
    this.setProperty("selectedPair",
      this.adjustPreferredPairs(selectedPair));
  }

  adjustPreferredPairs(pair) {
    const pairs = this.availablePairs;
    if (pairs.find((p) => p.name == pair )) {
      return pair;
    } else {
      return pairs.length > 0 ? pairs[0].name : null;
    }
  }
}
