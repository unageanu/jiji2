import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import AgentSettingBuilder from "../../model/trading/agent-setting-builder"

export default class RMTAgentSettingPageModel extends Observable {

  constructor() {
    super();
    this.agentClasses = ContainerJS.Inject;
    this.rmtService   = ContainerJS.Inject;
  }

  postCreate() {
    this.agentSettingBuilder = new AgentSettingBuilder(this.agentClasses);
  }

  initialize() {
    return this.rmtService.getAgentSetting().then((setting) => {
      this.agentSettingBuilder.initialize(setting);
    });
  }

  saveAgentSetting() {
    const agentSetting = this.agentSettingBuilder.agentSetting;
    return this.rmtService.putAgentSetting(agentSetting).then(
      (saved) => this.agentSettingBuilder.agentSetting = saved );
  }

}
