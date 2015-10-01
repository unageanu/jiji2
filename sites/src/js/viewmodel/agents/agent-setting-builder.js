import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"
import IconSelector    from "../icons/icon-selector-model"

export default class AgentSettingBuilder extends Observable {

  constructor(agentClasses, icons, validator=null) {
    super();
    this.agentClasses = agentClasses;
    this.validator    = validator;

    this.availableAgents = [];
    this.agentSetting    = [];

    this.iconSelector = new IconSelector(this.icons);
  }

  initialize(agents=[]) {
    this.agentSetting = agents || [];
    this.agentSettingError = null;
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

  validate() {
    if (!this.validator) return true;
    return ValidationUtils.validate(this.validator, this.agentSetting,
      {field: "エージェント"}, (error) => this.agentSettingError = error );
  }

  convert(agents) {
    return agents.map((a) => {
      a.agentName = a.name;
      return a;
    });
  }

  get availableAgents() {
    return this.getProperty("availableAgents");
  }
  set availableAgents(agents) {
    this.setProperty("availableAgents", agents);
  }

  set agentSetting(setting) {
    return this.setProperty("agentSetting", this.convert(setting));
  }
  get agentSetting() {
    return this.getProperty("agentSetting");
  }

  get agentSettingError() {
    return this.getProperty("agentSettingError");
  }
  set agentSettingError(error) {
    this.setProperty("agentSettingError", error);
  }
}
