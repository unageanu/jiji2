import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import AgentSettingEditor from "../agents/agent-setting-editor"
import LoadingImage       from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;

const keys = new Set([
  "isSaving", "isLoading", "savedLabel"
]);

export default class RMTAgentSettingPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize();

    this.registerPropertyChangeListener(model, keys);
    const state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    if (this.state.isLoading) {
      return <div className="center-information">
        <LoadingImage left={-20}/>
      </div>;
    }
    return (
      <div className="rmt-agent-setting-page">
        <div className="top-button">
          <RaisedButton
            label="設定を反映"
            primary={true}
            disabled={this.state.isSaving}
            onClick={this.save.bind(this)}
          />
          <span className="saved-label">{
            this.state.isSaving
              ? <LoadingImage width={20} />
              : this.state.savedLabel
          }</span>
        </div>
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
};
