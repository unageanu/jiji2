import React               from "react"
import { injectIntl }      from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import AgentSelectorDialog from "./agent-selector-dialog"
import IconSelector        from "../icons/icon-selector"
import AgentIcon           from "../widgets/agent-icon"
import ConfirmDialog       from "../widgets/confirm-dialog"

import IconButton from "material-ui/IconButton"
import FontIcon from "material-ui/FontIcon"

const keys = new Set([
  "availableAgents", "selectedAgent"
]);

class AgentSettingEditorMenu extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    const state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="agent-setting-editor-menu">
        <IconButton
          key="add"
          tooltip={formatMessage({ id: 'agents.AgentSettingEditorMenu.add' })}
          onClick={this.showAgentSelector.bind(this)}>
          <FontIcon className="md-add"/>
        </IconButton>
        <IconButton
          key="remove"
          tooltip={formatMessage({ id: 'agents.AgentSettingEditorMenu.remove' })}
          onClick={this.removeAgent.bind(this)}
          disabled={this.state.selectedAgent == null}>
          <FontIcon className="md-remove"/>
        </IconButton>
        <AgentSelectorDialog
          ref={(ref) => this.agentSelectorDialog = ref}
          availableAgents={this.state.availableAgents}
          onSelect={this.addAgent.bind(this)} />
        <ConfirmDialog
          ref={(ref) => this.confirmDialog = ref}
          text={formatMessage({ id: 'agents.AgentSettingEditorMenu.confirmRemove' })} />
      </div>
    );
  }

  showAgentSelector() {
    this.agentSelectorDialog.show();
  }

  addAgent(agent) {
    this.props.model.addAgent( agent.name );
    this.agentSelectorDialog.dismiss();
  }
  removeAgent() {
    this.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.props.model.removeSelectedAgent();
    });
  }
}
AgentSettingEditorMenu.propTypes = {
  model : React.PropTypes.object.isRequired
};

export default injectIntl(AgentSettingEditorMenu);
