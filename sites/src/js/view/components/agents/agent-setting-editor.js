import React              from "react"
import MUI                from "material-ui"
import AbstractComponent  from "../widgets/abstract-component"
import AgentClassSelector from "./agent-class-selector"
import IconSelector       from "../icons/icon-selector"
import AgentIcon          from "../widgets/agent-icon"

const RaisedButton = MUI.RaisedButton;
const List         = MUI.List;
const ListItem     = MUI.ListItem;
const Dialog       = MUI.Dialog;
const TextField    = MUI.TextField;

const keys = new Set([
  "availableAgents", "agentSetting", "agentSettingError", "selectedAgent"
]);

let counter = 0;

export default class AgentSettingEditor extends AbstractComponent {

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
    const agents        = this.createAgents();
    const dialogActions=[
      { text: "Cancel", onTouchTap: () => this.refs.agentSelectorDialog.dismiss() }
    ];
    const agentDetails  = this.createAgentDetail();
    return (
      <div className="agent-setting-editor">
        <div className="error">{this.state.agentSettingError}</div>
        <div className="action">
          <RaisedButton
            label="エージェントを追加"
            onClick={this.showAgentSelector.bind(this)}
          />
          <Dialog
            ref="agentSelectorDialog"
            title=""
            actions={dialogActions}
            modal={true}
          >
          <div>
           <div>追加するエージェントを選択してください。</div>
           <AgentClassSelector
            classes={this.state.availableAgents}
            onSelect={this.addAgent.bind(this)}
            />
          </div>
          </Dialog>
        </div>
        <div>
          <div className="agent-list">
            <List>{agents}</List>
          </div>
          <div className="agent-details">
            {agentDetails}
          </div>
        </div>
      </div>
    );
  }

  createAgents() {
    return this.state.agentSetting.map((agent, index) => {
      const selected  = this.state.selectedAgent === agent;
      const tapAction = (ev) => {
        this.applyAgentConfiguration();
        this.props.model.selectedAgent = agent;
      };
      const avatar =  <AgentIcon
            iconId={agent.iconId}
            urlResolver={this.props.model.agentClasses.agentService.urlResolver} />;
      return <ListItem
            key={index}
            className={selected ? "selected" : ""}
            leftAvatar={avatar}
            onTouchTap={tapAction}
            primaryText={agent.agentName}>
          </ListItem>;
    });
  }

  createAgentDetail() {
    const selectedAgent = this.state.selectedAgent;
    if (selectedAgent == null) return null;

    const agentClass =  this.props.model.getAgentClassForSelected();
    const agentPropertyEditors =
      this.createAgentPropertyEditor(selectedAgent, agentClass);
    const agentNameEditor =
      this.createAgentNameEditor(selectedAgent, agentClass);
    return <div className="agent-details" key={counter++}>
      <div className="agent-class">{selectedAgent ? selectedAgent.agentClass : ""}</div>
      <div className="description">{agentClass ? agentClass.description : ""}</div>
      <div className="icon"><IconSelector model={this.props.model.iconSelector} /></div>
      <div className="agentName">{agentNameEditor}</div>
      <div className="properties">
        {agentPropertyEditors}
      </div>
    </div>;
  }

  createAgentNameEditor(selectedAgent, agentClass) {
    if (!selectedAgent || !agentClass) return null;
    const name = selectedAgent.agentName || selectedAgent.agentClass;
    return <TextField
      ref={"agent_name"}
      floatingLabelText="エージェントの名前"
      defaultValue={name} />;
  }

  createAgentPropertyEditor(selectedAgent, agentClass) {
    if (!selectedAgent || !agentClass) return null;
    return agentClass.properties.map((p) => {
      const value = selectedAgent.properties[p.id] || p.default;
      return  <TextField
          ref={"agent_properties_" + p.id}
          key={p.id}
          floatingLabelText={p.name}
          defaultValue={value} />;
    });
  }

  applyAgentConfiguration() {
    if (this.state.selectedAgent == null) return;
    const agentClass =  this.props.model.getAgentClassForSelected();
    const agentName = this.refs.agent_name.getValue();
    const iconId = this.props.model.iconSelector.selectedId;
    const configuration = agentClass.properties.reduce((r, p) => {
      r[p.id] = this.refs["agent_properties_" + p.id].getValue();
      return r;
    }, {});
    this.props.model.updateSelectedAgent(
      agentName, iconId, configuration);
  }

  showAgentSelector() {
    this.refs.agentSelectorDialog.show();
  }

  addAgent(agent) {
    this.applyAgentConfiguration();
    this.props.model.addAgent( agent.name );
    this.refs.agentSelectorDialog.dismiss();
  }
}
AgentSettingEditor.propTypes = {
  model : React.PropTypes.object.isRequired
};
