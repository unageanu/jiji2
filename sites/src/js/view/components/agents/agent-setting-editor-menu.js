import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import AgentSelectorDialog from "./agent-selector-dialog"
import IconSelector        from "../icons/icon-selector"
import AgentIcon           from "../widgets/agent-icon"
import ConfirmDialog       from "../widgets/confirm-dialog"

const IconButton = MUI.IconButton;
const FontIcon   = MUI.FontIcon;

const keys = new Set([
  "availableAgents", "selectedAgent"
]);

export default class AgentSettingEditorMenu extends AbstractComponent {

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
    return (
      <div className="agent-setting-editor-menu">
        <IconButton
          key="add"
          tooltip={"エージェントを追加"}
          onClick={this.showAgentSelector.bind(this)}>
          <FontIcon className="md-add"/>
        </IconButton>
        <IconButton
          key="remove"
          tooltip={"選択したエージェントを削除"}
          onClick={this.removeAgent.bind(this)}
          disabled={this.state.selectedAgent == null}>
          <FontIcon className="md-remove"/>
        </IconButton>
        <AgentSelectorDialog
          ref="agentSelectorDialog"
          availableAgents={this.state.availableAgents}
          onSelect={this.addAgent.bind(this)} />
        <ConfirmDialog
          ref="confirmDialog"
          text="選択したエージェントを削除します。よろしいですか?" />
      </div>
    );
  }

  showAgentSelector() {
    this.refs.agentSelectorDialog.show();
  }

  addAgent(agent) {
    this.props.model.addAgent( agent.name );
    this.refs.agentSelectorDialog.dismiss();
  }
  removeAgent() {
    this.refs.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.props.model.removeSelectedAgent();
    });
  }
}
AgentSettingEditorMenu.propTypes = {
  model : React.PropTypes.object.isRequired
};
