import React      from "react"
import Router     from "react-router"
import MUI        from "material-ui"
import AgentIcon  from "../widgets/agent-icon"

const ListItem     = MUI.ListItem;

export default class AgentListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const agent = this.props.agent;
    const avatar = <AgentIcon
          iconId={agent.iconId}
          urlResolver={this.props.urlResolver} />;
    const className =
      "agent-list-item " + (this.props.selected ? "selected" : "");
    return <ListItem
          className={className}
          leftAvatar={avatar}
          onTouchTap={(ev)=> this.props.onTouchTap(ev, agent ) }
          primaryText={agent.agentName}>
        </ListItem>;
  }
}
 AgentListItem.propTypes = {
  agent : React.PropTypes.object.isRequired,
  urlResolver: React.PropTypes.object.isRequired,
  onTouchTap : React.PropTypes.func,
  selected: React.PropTypes.bool
};
 AgentListItem.defaultProps = {
  onTouchTap: (ev, agent) => {},
  selected: false
};
