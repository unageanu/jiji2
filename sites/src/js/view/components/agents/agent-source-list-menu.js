import React               from "react"
import { injectIntl }      from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"

import RaisedButton from "material-ui/RaisedButton"

import IconButton from "material-ui/IconButton"
import FontIcon from "material-ui/FontIcon"

class AgentSourceListMenu extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="agent-source-list-menu">
        <IconButton
          key="newFile"
          tooltip={formatMessage({ id: 'agents.AgentSourceListMenu.newFile' })}
          onTouchTap={this.createNewFile.bind(this)}>
          <FontIcon className="md-add"/>
        </IconButton>
      </div>
    );
  }

  createNewFile(ev) {
    this.editor().newSourceFile();
    ev.preventDefault();
  }

  editor() {
    return this.props.model;
  }
}
AgentSourceListMenu.propTypes = {
  model: React.PropTypes.object.isRequired
};

export default injectIntl(AgentSourceListMenu);
