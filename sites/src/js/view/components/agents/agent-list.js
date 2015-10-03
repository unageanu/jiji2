import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"
import AgentSettingEditorMenu from "./agent-setting-editor-menu"
import AgentListItem          from "./agent-list-item"

const List         = MUI.List;

const keys = new Set([
  "availableAgents", "agentSetting"
]);

export default class AgentList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      availableAgents:    [],
      agentSetting:       [],
      selectedAgentIndex: -1
    };
  }

  componentWillMount() {
    const model = this.props.model;
    const observer = (n, ev) => this.setState({agents:ev.agents});
    ["agentAdded", "agentRemoved"].forEach(
      (e) => model.addObserver(e, observer, this));
    this.registerPropertyChangeListener(model, keys);
    const state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    return (
      <div className="agent-list">
        <AgentSettingEditorMenu model={this.props.model}/>
        <List>{this.createAgents()}</List>
      </div>
    );
  }

  createAgents() {
    const model = this.props.model;
    return this.state.agentSetting.map((agent, index) => {
      const selected  = this.state.selectedAgent === agent;
      const tapAction = (ev, agent) => model.selectedAgent = agent;
      return <AgentListItem
              key={index}
              agent={agent}
              onTouchTap={tapAction}
              selected={selected}
              urlResolver={model.agentClasses.agentService.urlResolver} />
    });
  }
}
AgentList.propTypes = {
  model : React.PropTypes.object.isRequired
};
