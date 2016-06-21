import React       from "react"
import Router      from "react-router"

import Environment from "../../environment"

import {List, ListItem} from "material-ui/List"

export default class AgentClassSelector extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const items = this.props.classes.map(
      (agentClass) => this.createItemcomponent(agentClass));
    return (
      <div className="agent-class-list">
        <List>{items}</List>
      </div>
    );
  }

  createItemcomponent(agentClass) {
    const tapAction = (e) => {
      this.props.onSelect(agentClass);
      e.preventDefault();
    };
    const props = {
      className: "list-item",
      key: agentClass.name,
      onTouchTap: tapAction,
      primaryText: <div className="primaryText">{agentClass.name}</div>,
      secondaryText: agentClass.description
    };
    return Environment.get().createListItem(props);
  }
}
AgentClassSelector.propTypes = {
  classses : React.PropTypes.array,
  onSelect : React.PropTypes.func
};
AgentClassSelector.defaultProps = {
  classses: [],
  onSelect: (agentClass) => {}
};
AgentClassSelector.contextTypes = {
  application: React.PropTypes.object.isRequired
};
