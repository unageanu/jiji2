import React          from "react"
import { FormattedMessage } from 'react-intl';

import Deferred     from "../../../utils/deferred"

import Dialog from "material-ui/Dialog"
import FlatButton from "material-ui/FlatButton"

export default class ConfirmDialog extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }

  render() {
    return (
      <Dialog
        key="dialog"
        className="confilm-dialog"
        open={this.state.open}
        actions={this.createActions()}
        modal={true}
      >
        <div className="dialog-content">
          <div className="dialog-description">{this.props.text}</div>
        </div>
      </Dialog>
    );
  }

  createActions() {
    return this.props.actions.map((a) => {
      const touchAction = (ev) => {
        if ( this.state.d ) this.state.d.resolve(a.id);
        this.setState({d:null, open:false})
      };
      return <FlatButton
        label={a.text || <FormattedMessage id={a.labelId} />}
        primary={false}
        onTouchTap={touchAction}
      />
    })
  }

  confilm() {
    const d = new Deferred();
    this.setState({d:d,open:true})
    return d;
  }
}
ConfirmDialog.propTypes = {
  text:    React.PropTypes.string.isRequired,
  actions: React.PropTypes.array
};
ConfirmDialog.defaultProps = {
  actions: [
    { labelId: "common.button.no",  id:"no"  },
    { labelId: "common.button.yes", id:"yes" }
  ]
};
