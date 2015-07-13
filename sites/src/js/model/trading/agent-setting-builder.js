import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Validators   from "../../utils/validation/validators"

export default class AgentSettingBuilder extends Observable {

  constructor(agentClasses) {
    super();
    this.agentClasses = agentClasses;

    this.availableAgents = [];
    this.agentSetting    = [];
  }

  initialize(agents=[]) {
    this.agentSetting = agents || [];
    return this.agentClasses.load().then(() => {
      this.availableAgents = this.agentClasses.classes;
    });
  }

  getAgentClass(index) {
    const setting = this.agentSetting[index];
    return this.agentClasses.classes.find(
      (a) => a.name === setting.agentClass );
  }

  addAgent( agentClass, configuration={} ) {
    this.agentSetting.push({
      agentClass: agentClass,
      agentName:  agentClass,
      properties: configuration
    });
    this.fire("agentAdded", {agents:this.settings});
    return this.agentSetting.length -1;
  }
  removeAgent( index ) {
    this.agentSetting.splice(index, 1);
    this.fire("agentRemoved", {agents:this.settings});
  }
  updateAgentConfiguration(index, name, configuration) {
    this.agentSetting[index].agentName  = name;
    this.agentSetting[index].properties = configuration;
  }

  get availableAgents() {
    return this.getProperty("availableAgents");
  }
  set availableAgents(agents) {
    this.setProperty("availableAgents", agents);
  }

  set agentSetting(setting) {
    return this.setProperty("agentSetting", setting);
  }
  get agentSetting() {
    return this.getProperty("agentSetting");
  }
}
