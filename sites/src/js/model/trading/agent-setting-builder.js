import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Validators   from "../../utils/validation/validators"

export default class AgentSettingBuilder extends Observable {

  constructor(agentClasses) {
    super();
    this.agentClasses = agentClasses;

    this.availableAgents = [];
  }

  initialize(agents=[]) {
    this.settings = agents || [];
    return this.agentClasses.load().then(() => {
      this.availableAgents = this.agentClasses.classes;
    });
  }

  getAgentClass(index) {
    const settings = this.settings[index];
    return this.agentClasses.classes.find(
      (a) => a.name === settings.agentClass );
  }

  addAgent( agentClass, configuration={} ) {
    this.settings.push({
      agentClass: agentClass,
      agentName:  agentClass,
      properties: configuration
    });
    this.fire("agentAdded", {agents:this.settings});
    return this.settings.length -1;
  }
  removeAgent( index ) {
    this.settings.splice(index, 1);
    this.fire("agentRemoved", {agents:this.settings});
  }
  updateAgentConfiguration(index, name, configuration) {
    this.settings[index].agentName  = name;
    this.settings[index].properties = configuration;
  }

  get availableAgents() {
    return this.getProperty("availableAgents");
  }
  set availableAgents(agents) {
    this.setProperty("availableAgents", agents);
  }

  get agentSetting() {
    return this.settings;
  }
}
