import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class RMTAgentSettingPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory = ContainerJS.Inject;
  }

  postCreate() {
  }

}
