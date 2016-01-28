import ContainerJS          from "container-js"
import BasicPairSelector    from "./basic-pair-selector"

export default class PreferencesPairSelector extends BasicPairSelector {

  constructor(pairs, preferences) {
    super(pairs, null);

    this.preferences = preferences;
    this.registerPreferencesObservers();
    this.setProperty("selectedPair",   preferences.preferredPair);
  }

  registerPreferencesObservers() {
    this.preferences.addObserver("propertyChanged", (n, e) => {
      if (e.key != "preferredPairs") return;
      this.setProperty("selectedPair", this.preferences.preferredPair);
    }, this);
  }

  unregisterObservers() {
    super.unregisterObservers();
    this.pairs.removeAllObservers(this);
  }

  onPairChanged(n, e) {
    this.setProperty("availablePairs", e.newValue);
  }

  get selectedPair() {
    return this.getProperty("selectedPair");
  }
  set selectedPair(selectedPair) {
    if (!this.preferences) return null;
    this.preferences.preferredPair = selectedPair;
  }
}
