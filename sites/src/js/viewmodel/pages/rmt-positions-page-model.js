import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTPositionsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.positionTable =
      this.viewModelFactory.createPositionsTableModel(100, {
        order:     "profit_or_loss",
        direction: "desc"
      });
    this.positionTable.initialize("rmt", "live");
  }

  initialize( ) {
    this.positionTable.load();
  }

}
