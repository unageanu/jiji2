import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import AgentSettingEditor from "../widgets/agent-setting-editor"

const RaisedButton = MUI.RaisedButton;

export default class RMTAgentSettingPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.model().initialize();
  }

  render() {
    return (
      <div>
      <RaisedButton
        label="設定を保存"
        onClick={this.save.bind(this)}
        />
        <AgentSettingEditor
          ref="agentSettingEditor"
          model={this.model().agentSettingBuilder}/>
      </div>
    );
  }

  save() {
    this.refs.agentSettingEditor.applyAgentConfiguration();
    this.model().saveAgentSetting();
  }

  model() {
    return this.context.application.rmtAgentSettingPageModel;
  }
}
RMTAgentSettingPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
