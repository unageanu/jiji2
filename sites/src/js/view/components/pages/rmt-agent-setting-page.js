import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractPage       from "./abstract-page"
import AgentSettingEditor from "../agents/agent-setting-editor"
import LoadingImage       from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import Card from "material-ui/Card"

const keys = new Set([
  "isSaving", "isLoading", "savedLabel"
]);

export class RMTAgentSettingPage extends AbstractPage {

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
    return (
      <div className="rmt-agent-setting-page page">
        <Card className="main-card">
          {this.createContent()}
        </Card>
      </div>
    );
  }

  createContent() {
    if (this.state.isLoading) {
      return <div className="center-information">
        <LoadingImage left={-20}/>
      </div>;
    }
    const { formatMessage } = this.props.intl;
    return (
      <div>
        <ul className="description">
          <li><FormattedMessage id='pages.RMTAgentSettingPage.description' /></li>
        </ul>
        <div className="top-button">
          <RaisedButton
            label={formatMessage({ id: 'pages.RMTAgentSettingPage.apply' })}
            primary={true}
            disabled={this.state.isSaving}
            onClick={this.save.bind(this)}
            style={{width:"200px"}}
          />
          <span className="saved-label">{
            this.state.isSaving
              ? <LoadingImage size={20} />
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
    const { formatMessage } = this.props.intl;
    this.refs.agentSettingEditor.applyAgentConfiguration();
    this.model().saveAgentSetting(formatMessage);
  }

  model() {
    return this.context.application.rmtAgentSettingPageModel;
  }
}
RMTAgentSettingPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
};
export default injectIntl(RMTAgentSettingPage)
