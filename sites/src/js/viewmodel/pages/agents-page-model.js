import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class AgentsPageModel extends Observable {

  constructor() {
    super();

    this.agentSourceEditor = ContainerJS.Inject;
  }

  postCreate() {}

  initialize() {
    this.agentSourceEditor.load();
  }
}
