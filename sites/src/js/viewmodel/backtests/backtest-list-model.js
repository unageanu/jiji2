import ContainerJS from "container-js"
import Observable  from "../../utils/observable"


export default class BacktestListModel extends Observable {

  constructor(backtests) {
    super();
    this.backtests = backtests;
    this.registerObservers();
  }

  initialize( ) {
    this.setProperty("items", []);
  }

  registerObservers() {
    const backtests = this.backtests;
    const handler = () => this.setProperty("items", backtests.tests);
    ["loaded", "added", "updated", "removed", "updateStates"].forEach(
      (e) => backtests.addObserver(e, handler, this)
    );
  }

  get items() {
    this.getProperty("items");
  }

}
