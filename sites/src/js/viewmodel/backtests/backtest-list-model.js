import ContainerJS   from "container-js"
import Observable    from "../../utils/observable"
import BacktestModel from "./backtest-model"

export default class BacktestListModel extends Observable {

  constructor(backtests) {
    super();
    this.backtests = backtests;
    this.setProperty("items", null );
    this.registerObservers();
  }

  registerObservers() {
    const backtests = this.backtests;
    const handler = () => {
      this.setProperty("items",
        backtests.tests.map((m) => new BacktestModel(m)), () => false);
    };
    ["loaded", "added", "updated", "removed", "updateStates"].forEach(
      (e) => backtests.addObserver(e, handler, this)
    );
  }

  remove(id) {
    return this.backtests.remove( id );
  }

  get items() {
    return this.getProperty("items");
  }

}
