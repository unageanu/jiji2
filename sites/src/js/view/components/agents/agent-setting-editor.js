import React                  from "react"

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
    const menu   = !this.props.readOnly
      ? <AgentSettingEditorMenu model={this.props.model} />
      : null;
    return (
      <div className="agent-setting-editor">
        {this.createErrorContent(this.state.agentSettingError)}
        <div className="parent">
          <div className="agent-list">
            {menu}
            <AgentList model={this.props.model} />
          </div>
          <AgentPropertyEditor
            ref={(ref) => this.agentPropertyEditor = ref}
            readOnly={this.props.readOnly}
            model={this.props.model} />
        </div>
      </div>
    );
  }

  applyAgentConfiguration() {
    this.agentPropertyEditor.getWrappedInstance().applyAgentConfiguration();
  }
}
AgentSettingEditor.propTypes = {
  model : React.PropTypes.object.isRequired,
  readOnly : React.PropTypes.bool
};
AgentSettingEditor.defaultProps = {
  readOnly : false
};
