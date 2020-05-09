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

    this.iconSelector = new IconSelector(icons);
  }

  initialize(agents=[]) {
    this.iconSelector.initialize(null);
    this.agentSetting = agents || [];
    this.selectedAgent = null;
    this.agentSettingError = null;
    return this.agentClasses.load().then(() => {
      this.availableAgents = this.agentClasses.classes;
    });
  }

  getAgentClassForSelected() {
    if (this.selectedAgent == null) return;
    return this.agentClasses.classes.find(
      (a) => a.name === this.selectedAgent.agentClass );
  }

  addAgent( agentClass, configuration={} ) {
    this.agentSetting.push({
      agentClass: agentClass,
      agentName:  agentClass,
      properties: configuration
    });
    this.selectedAgent = this.agentSetting[this.agentSetting.length-1];
    this.fire("agentAdded", {agents:this.settings});
  }
  removeSelectedAgent( ) {
    if (this.selectedAgent == null) return;
    this.agentSetting = this.agentSetting.filter( (a) => a != this.selectedAgent );
    this.selectedAgent = null;
    this.fire("agentRemoved", {agents:this.settings});
  }
  updateSelectedAgent(name, iconId=null, configuration={}) {
    if (this.selectedAgent == null) return;
    this.selectedAgent.agentName  = name;
    this.selectedAgent.iconId     = iconId;
    this.selectedAgent.properties = configuration;
  }

  validate(formatMessage) {
    if (!this.validator) return true;
    return ValidationUtils.validate(this.validator, this.agentSetting,
      {field: formatMessage({id:'validation.fields.agent'})}, (error) => this.agentSettingError = error, formatMessage );
  }

  convert(agents) {
    return agents.map((a) => {
      a.agentName = a.name || a.agentName;
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
    this.setProperty("agentSetting", this.convert(setting));
  }
  get agentSetting() {
    return this.getProperty("agentSetting");
  }

  set selectedAgent(selectedAgent) {
    this.fire("beforeSeletionChange",
      {current: this.selectedAgent, new:selectedAgent});
    this.setProperty("selectedAgent", selectedAgent, () => false);
    this.iconSelector.selectedId = selectedAgent ? selectedAgent.iconId : null;
  }
  get selectedAgent() {
    return this.getProperty("selectedAgent");
  }

  get agentSettingError() {
    return this.getProperty("agentSettingError");
  }
  set agentSettingError(error) {
    this.setProperty("agentSettingError", error);
  }
}
