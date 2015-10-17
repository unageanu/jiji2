import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"
import IconSelector           from "../icons/icon-selector"

const TextField    = MUI.TextField;

const keys = new Set([
  "selectedAgent"
]);

let counter = 0;

export default class AgentPropertyEditor extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.props.model;
    model.addObserver("beforeSeletionChange",
      this.applyAgentConfiguration.bind(this), this);
    this.registerPropertyChangeListener(model, keys);
    const state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    return (
      <div className="agent-property-editor">
        {this.createEditor()}
      </div>
    );
  }

  createEditor() {
    const selectedAgent = this.state.selectedAgent;
    if (selectedAgent == null) return null;

    const agentClass =  this.props.model.getAgentClassForSelected();
    const agentPropertyEditors =
      this.createAgentPropertyEditor(selectedAgent, agentClass);
    const agentNameEditor =
      this.createAgentNameEditor(selectedAgent, agentClass);
    return <div className="agent-details" key={counter++}>
      <div className="agent-class item">
        <span className="item-label">クラス:</span>
        <span className="item-value">{selectedAgent ? selectedAgent.agentClass : ""}</span>
      </div>
      <div className="description item">
        <span className="item-label">説明:</span>
        <div className="item-value">
          <pre>
            {agentClass ? agentClass.description : ""}
          </pre>
        </div>
      </div>
      <div className="icon-and-name item">
        <div className="icon">
          <IconSelector
            model={this.props.model.iconSelector}
            readOnly={this.props.readOnly} />
        </div>
        <div className="agent-name">{agentNameEditor}</div>
      </div>
      <div className="properties">
        {agentPropertyEditors}
      </div>
    </div>;
  }

  createAgentNameEditor(selectedAgent, agentClass) {
    if (!selectedAgent || !agentClass) return null;
    const name = selectedAgent.agentName || selectedAgent.agentClass;
    if (this.props.readOnly) {
      return <div className="agent-name item">
        <span className="item-label">エージェントの名前:</span>
        <div className="item-value">{name}</div>
      </div>;
    } else {
      return <TextField
        ref={"agent_name"}
        key={"agent_name"}
        floatingLabelText="エージェントの名前"
        defaultValue={name}
        style={{
          width: "100%"
        }} />;
    }
  }

  createAgentPropertyEditor(selectedAgent, agentClass) {
    if (!selectedAgent || !agentClass) return null;
    return agentClass.properties.map((p) => {
      const value = selectedAgent.properties[p.id] || p.default;
      if (this.props.readOnly) {
        return <div key={p.id} className="property item">
          <span className="item-label">{p.name}:</span>
          <div className="item-value">{value}</div>
        </div>;
      } else {
        return <div key={p.id} className="property">
            <TextField
              ref={"agent_properties_" + p.id}
              key={p.id}
              floatingLabelText={p.name}
              defaultValue={value}
              style={{
                width: "100%"
              }}/>
          </div>;
      }
    });
  }

  applyAgentConfiguration() {
    if (this.props.readOnly) return;
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
}
AgentPropertyEditor.propTypes = {
  model : React.PropTypes.object.isRequired,
  readOnly : React.PropTypes.bool
};
AgentPropertyEditor.defaultProps = {
  readOnly : false
};
