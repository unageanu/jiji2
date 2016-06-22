import React         from "react"
import { Router } from 'react-router'

import AgentIcon     from "../widgets/agent-icon"
import Environment   from "../../environment"
import Theme         from "../../theme"
import DateFormatter from "../../../viewmodel/utils/date-formatter"

import FontIcon from "material-ui/FontIcon"

export default class AgentSourceListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const agentSource = this.props.agentSource;
    const className =
      "list-item " + (this.props.selected ? "selected" : "");
    const props = {
      key: agentSource.id,
      className: className,
      innerDivStyle : Object.assign({}, Theme.listItem.innerDivStyle, {
        backgroundColor: this.props.selected
          ? Theme.palette.backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }),
      onTouchTap: this.props.onTouchTap,
      primaryText: <div className="primary-text">{agentSource.name}</div>,
      secondaryText: this.createSecondaryText(),
      rightIcon: this.createRightIcon()
    };
    return Environment.get().createListItem(props);
  }

  createSecondaryText() {
    const agentSource = this.props.agentSource;
    return <div key="updated-at">
      {DateFormatter.format(agentSource.updatedAt)}
    </div>;
  }

  createRightIcon() {
    const agentSource = this.props.agentSource;
    if (agentSource.status !== "error") return null;
    return <span className="right-icon warn">
      <FontIcon
        style={{color: Theme.palette.negativeColor}}
        className="md-warning"/>
    </span>;
  }
}
AgentSourceListItem .propTypes = {
  agentSource : React.PropTypes.object.isRequired,
  onTouchTap : React.PropTypes.func,
  selected: React.PropTypes.bool
};
AgentSourceListItem .defaultProps = {
  onTouchTap: (ev, agent) => {},
  selected: false
};
