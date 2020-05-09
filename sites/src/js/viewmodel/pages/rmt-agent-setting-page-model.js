import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import AgentSettingBuilder from "../agents/agent-setting-builder"
import AbstractPageModel   from "./abstract-page-model"
import DateFormatter       from "../utils/date-formatter"

export default class RMTAgentSettingPageModel extends AbstractPageModel {

  constructor() {
    super();
    this.agentClasses = ContainerJS.Inject;
    this.rmtService   = ContainerJS.Inject;
    this.icons        = ContainerJS.Inject;
    this.timeSource   = ContainerJS.Inject;

    this.isLoading  = true;
    this.savedLabel = null;
  }

  postCreate() {
    this.agentSettingBuilder =
      new AgentSettingBuilder(this.agentClasses, this.icons);
  }

  initialize() {
    this.savedLabel = null;
    return this.rmtService.getAgentSetting().then((setting) => {
      this.isLoading = false;
      this.agentSettingBuilder.initialize(setting);
    });
  }

  saveAgentSetting(formatMessage) {
    this.isSaving   = true;
    this.savedLabel = null;
    const agentSetting = this.agentSettingBuilder.agentSetting;
    return this.rmtService.putAgentSetting(agentSetting).then(
      (saved) => {
        this.agentSettingBuilder.agentSetting = saved;
        this.isSaving   = false;
        this.savedLabel = `※${formatMessage({ id: 'validation.messages.finishToChangeSetting' })} ( ` +
          DateFormatter.format(this.timeSource.now) + " )";
      },
      () => this.isSaving = false );
  }

  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
  get isSaving() {
    return this.getProperty("isSaving");
  }
  set savedLabel(savedLabel) {
    this.setProperty("savedLabel", savedLabel);
  }
  get savedLabel() {
    return this.getProperty("savedLabel");
  }
}
