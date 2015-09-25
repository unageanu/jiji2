import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTPositionsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.positionTable =
      this.viewModelFactory.createPositionsTableModel(50, {
        order:     "profit_or_loss",
        direction: "desc"
      });
    this.selection =
        this.viewModelFactory.createPositionSelectionModel();
    this.selection.attach(this.positionTable);
  }

  initialize( selectedId ) {
    this.positionTable.initialize("rmt", "live");
    this.positionTable.load().then(
      () => this.selection.selectedId = selectedId );
  }

}
