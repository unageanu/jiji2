import React                from "react"
import { FormattedMessage } from 'react-intl';

import AgentClassSelector from "./agent-class-selector"
import Theme              from "../../theme"

import Dialog from "material-ui/Dialog"
import FlatButton from "material-ui/FlatButton"

export default class AgentSelectorDialog extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }

  render() {
    const actions = [
      <FlatButton
        label="aaa"
        label={<FormattedMessage id="common.button.cancel"/>}
        primary={false}
        onTouchTap={this.dismiss.bind(this)}
      />
    ];
    return (
      <Dialog
        open={this.state.open}
        actions={actions}
        modal={true}
        className="dialog"
        contentStyle={Theme.dialog.contentStyle}
        onRequestClose={this.dismiss.bind(this)}>
        <div className="dialog-content">
          <div className="dialog-description"><FormattedMessage id="agents.AgentSelectorDialog.description" /></div>
          <AgentClassSelector
            classes={this.props.availableAgents}
            onSelect={this.props.onSelect}
          />
        </div>
      </Dialog>
    );
  }

  show() {
    this.setState({open:true});
  }
  dismiss() {
    this.setState({open:false});
  }
}
AgentSelectorDialog.propTypes = {
  availableAgents : React.PropTypes.array,
  onSelect : React.PropTypes.func
};
AgentClassSelector.defaultProps = {
  availableAgents: [],
  onSelect: (agentClass) => {}
};
