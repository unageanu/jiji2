import React              from "react"
import MUI                from "material-ui"
import AbstractComponent  from "./abstract-component"
import AgentClassSelector from "./agent-class-selector"

const RaisedButton = MUI.RaisedButton;
const List         = MUI.List;
const ListItem     = MUI.ListItem;
const Dialog       = MUI.Dialog;
const TextField    = MUI.TextField;

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
    this.registerObservers();
    this.setState({
      availableAgents:    this.props.model.availableAgents,
      agentSetting:       this.props.model.agentSetting,
      selectedAgentIndex: -1
    });
  }
  componentWillUnmount() {
    this.unregisterObservers();
  }

  render() {
    const agents        = this.createAgents();
    const dialogActions=[
      { text: "Cancel", onTouchTap: () => this.refs.agentSelectorDialog.dismiss() }
    ];
    const agentDetails  = this.createAgentDetail();
    return (
      <div>
        <div className="agents">
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
      const selected  = this.state.selectedAgentIndex === index;
      const tapAction = (ev) => {
        this.applyAgentConfiguration();
        this.setState({selectedAgentIndex:index});
      };
      return <ListItem
            key={index}
            className={selected ? "mui-selected" : ""}
            onTouchTap={tapAction}
            primaryText={agent.agentName}>
          </ListItem>;
    });
  }

  createAgentDetail() {
    const selectedAgent = this.getSelectedAgent();
    const agentClass    = this.getAgentClass();
    const agentPropertyEditors =
      this.createAgentPropertyEditor(selectedAgent, agentClass);
    const agentNameEditor =
      this.createAgentNameEditor(selectedAgent, agentClass);
    return <div className="agent-details" key={this.state.selectedAgentIndex}>
      <div>{selectedAgent ? selectedAgent.agentClass : ""}</div>
      <div>{agentClass ? agentClass.description : ""}</div>
      <div>{agentNameEditor}</div>
      <div>
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
          floatingLabelText={p.name}
          defaultValue={value} />;
    });
  }

  applyAgentConfiguration() {
    const selectedAgent = this.getSelectedAgent();
    const agentClass    = this.getAgentClass();
    if (!selectedAgent) return;
    const agentName = this.refs.agent_name.getValue();
    const configuration = agentClass.properties.reduce((r, p) => {
      r[p.id] = this.refs["agent_properties_" + p.id].getValue();
      return r;
    }, {});
    this.props.model.updateAgentConfiguration(
      this.state.selectedAgentIndex, agentName, configuration);
  }

  getSelectedAgent() {
    if (this.state.selectedAgentIndex >= 0) {
      return this.props.model.agentSetting[this.state.selectedAgentIndex];
    } else {
      return null;
    }
  }
  getAgentClass() {
    if (this.state.selectedAgentIndex >= 0) {
      return this.props.model.getAgentClass(this.state.selectedAgentIndex);
    } else {
      return null;
    }
  }

  showAgentSelector() {
    this.refs.agentSelectorDialog.show();
  }

  addAgent(agent) {
    const index = this.props.model.addAgent( agent.name );
    this.refs.agentSelectorDialog.dismiss();

    this.applyAgentConfiguration();
    this.setState({selectedAgentIndex:index});
  }

  registerObservers() {
    const builder  = this.props.model;
    const observer = (n, ev) => this.setState({agents:ev.agents});
    ["agentAdded", "agentRemoved"].forEach(
      (e) => builder.addObserver(e, observer, this)
    );
    this.registerPropertyChangeListener(builder);
  }

  onPropertyChanged(k, ev) {
    if (ev.key === "agentSetting") {
      this.setState({selectedAgentIndex: -1});
    }
    super.onPropertyChanged(k, ev);
  }

  unregisterObservers() {
    this.props.model.removeAllObservers(this);
  }
}
AgentSettingEditor.propTypes = {
  model : React.PropTypes.object.isRequired
};
AgentSettingEditor.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
