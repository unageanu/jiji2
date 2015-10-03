import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"
import AgentList              from "./agent-list"
import AgentPropertyEditor    from "./agent-property-editor"

const keys = new Set([
  "agentSettingError"
]);

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
    this.registerPropertyChangeListener(model, keys);
    const state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    const error  = this.state.agentSettingError
      ? <div className="error">{this.state.agentSettingError}</div>
      : null
    return (
      <div className="agent-setting-editor">
        {error}
        <div className="parent">
          <AgentList model={this.props.model} />
          <AgentPropertyEditor
            ref="agentPropertyEditor"
            model={this.props.model} />
        </div>
      </div>
    );
  }

  applyAgentConfiguration() {
    this.refs.agentPropertyEditor.applyAgentConfiguration();
  }
}
AgentSettingEditor.propTypes = {
  model : React.PropTypes.object.isRequired
};
