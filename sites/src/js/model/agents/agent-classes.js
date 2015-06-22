import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Collections  from "../../utils/collections"

export default class AgentClasses extends Observable {

  constructor() {
    super();
    this.agentService = ContainerJS.Inject;
    this.classes = [];
    this.byName  = {};
  }

  load() {
    return this.agentService.getClasses().then((classes) => {
      this.classes = Collections.sortBy(classes, (item) => item.name);
      this.byName  = Collections.toMap(classes, (item) => item.name);
      this.fire("loaded", {items:this.classes});
    });
  }

  get(name) {
    return this.byName[name];
  }

}
