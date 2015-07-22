import ContainerJS from "container-js"
import Observable  from "../../utils/observable"


export default class BacktestListModel extends Observable {

  constructor(backtests) {
    super();
    this.backtests = backtests;
    this.setProperty("items", [] );
    this.registerObservers();
  }

  registerObservers() {
    const backtests = this.backtests;
    const handler = () =>
      this.setProperty("items", backtests.tests, () => false);
    ["loaded", "added", "updated", "removed", "updateStates"].forEach(
      (e) => backtests.addObserver(e, handler, this)
    );
  }

  get items() {
    return this.getProperty("items");
  }

}
