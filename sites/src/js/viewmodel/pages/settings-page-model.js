import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class SettingsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
  }

  initialize() {
  }
}
