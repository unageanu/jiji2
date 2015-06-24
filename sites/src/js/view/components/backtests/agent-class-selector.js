import React  from "react"
import Router from "react-router"
import MUI    from "material-ui"

const List         = MUI.List;
const ListItem     = MUI.ListItem;

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
    const tapAction = (e) => this.props.onSelect(agentClass);
    return (
      <ListItem
        key={agentClass.name}
        onTouchTap={tapAction}>
        {agentClass.name}
      </ListItem>
    );
  }
}
AgentClassSelector.propTypes = {
  classses : React.PropTypes.bool.isRequired,
  onSelect : React.PropTypes.func.isRequired
};
AgentClassSelector.defaultProps = {
  classses: [],
  onSelect: (agentClass) => {}
};
AgentClassSelector.contextTypes = {
  application: React.PropTypes.object.isRequired
};
