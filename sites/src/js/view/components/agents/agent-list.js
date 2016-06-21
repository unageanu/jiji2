import React                  from "react"

import AbstractComponent      from "../widgets/abstract-component"
import AgentListItem          from "./agent-list-item"

import {List} from "material-ui/List"

const keys = new Set([
  "availableAgents", "agentSetting", "selectedAgent"
]);

export default class AgentList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      availableAgents:    [],
      agentSetting:       []
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
      <List className="list">{this.createAgents()}</List>
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
