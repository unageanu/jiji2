import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Validators   from "../../utils/validation/validators"

export default class AgentSettingBuilder extends Observable {

  constructor(agentClasses) {
    super();
    this.agentClasses = agentClasses;
  }

  initialize(agents=[]) {
    this.agentSetting = agents || [];
    return Deferred.when([
      this.agentClasses.load()
    ]);
  }

  getAgentClass(index) {
    const agentSetting = this.agentSetting[index];
    return this.agentClasses.classes.find(
      (a) => a.name === agentSetting.agentClass );
  }

  addAgent( agentClass, configuration={} ) {
    this.agentSetting.push({
      agentClass: agentClass,
      agentName:  agentClass,
      properties: configuration
    });
    this.fire("agentAdded", {agents:this.agentSetting});
    return this.agentSetting.length -1;
  }
  removeAgent( index ) {
    this.agentSetting.splice(index, 1);
    this.fire("agentRemoved", {agents:this.agentSetting});
  }
  updateAgentConfiguration(index, name, configuration) {
    this.agentSetting[index].agentName  = name;
    this.agentSetting[index].properties = configuration;
  }

  toArray() {
    return this.agentSetting;
  }
}
