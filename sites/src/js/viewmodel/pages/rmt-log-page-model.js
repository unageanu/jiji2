import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTLogPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
    this.logViewerModel = this.viewModelFactory.createLogViewerModel();
    this.logViewerModel.initialize("rmt");
  }

  initialize( ) {
    this.logViewerModel.load();
  }

}
