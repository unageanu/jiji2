import React       from "react"
import Router      from "react-router"
import MUI         from "material-ui"
import AgentIcon   from "../widgets/agent-icon"
import Environment from "../../environment"
import Theme       from "../../theme"

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
      "list-item " + (this.props.selected ? "selected" : "");
    const props = {
      className: className,
      innerDivStyle : Object.assign({}, Theme.listItem.innerDivStyle, {
        backgroundColor: this.props.selected
          ? Theme.getPalette().backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }),
      leftAvatar: avatar,
      onTouchTap: (ev)=> this.props.onTouchTap(ev, agent ),
      primaryText: <div className="primary-text">{agent.agentName}</div>,
      secondaryText: this.createSecondaryText(),
      secondaryTextLines: 2
    };
    return Environment.get().createListItem(props);
  }

  createSecondaryText() {
    const agent = this.props.agent;
    return <div>
      <div key="agent-class">{agent.agentClass}</div>
      <div key="properties">{this.createProperySummary(agent)}</div>
    </div>;
  }

  createProperySummary(agent) {
    let str = [];
    for ( let key in agent.properties ) {
      str.push(key+"="+agent.properties[key]);
    }
    return str.join(" ");
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
