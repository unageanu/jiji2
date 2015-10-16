import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"
import AgentList              from "./agent-list"
import AgentPropertyEditor    from "./agent-property-editor"
import AgentSettingEditorMenu from "./agent-setting-editor-menu"

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
    const menu   = !this.props.readOnly
      ? <AgentSettingEditorMenu model={this.props.model} />
      : null;
    return (
      <div className="agent-setting-editor">
        {error}
        <div className="parent">
          <div className="agent-list">
            {menu}
            <AgentList model={this.props.model} />
          </div>
          <AgentPropertyEditor
            ref="agentPropertyEditor"
            readOnly={this.props.readOnly}
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
  model : React.PropTypes.object.isRequired,
  readOnly : React.PropTypes.bool
};
AgentSettingEditor.defaultProps = {
  readOnly : false
};
