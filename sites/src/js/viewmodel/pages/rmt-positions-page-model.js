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
        order:     "entered_at",
        direction: "desc"
      });
    this.selection =
        this.viewModelFactory.createPositionSelectionModel();
    this.selection.attach(this.positionTable);
    this.positionDownloader = this.viewModelFactory.createPositionDownloader();
  }

  initialize( selectedId ) {
    this.positionTable.initialize("rmt");
    this.positionDownloader.initialize();
    this.positionTable.load().then(
      () => this.selection.selectedId = selectedId
    , ( error ) => console.log(error) );
  }

}
