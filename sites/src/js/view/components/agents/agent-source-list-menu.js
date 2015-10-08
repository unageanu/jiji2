import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;

const IconButton = MUI.IconButton;
const FontIcon   = MUI.FontIcon;

export default class AgentSourceListMenu extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="agent-source-list-menu">
        <IconButton
          key="newFile"
          tooltip={"新規作成"}
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
