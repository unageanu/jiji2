import React        from "react"

import Deferred     from "../../../utils/deferred"

import Dialog from "material-ui/Dialog"

export default class ConfirmDialog extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Dialog
        key="dialog"
        ref="dialog"
        className="confilm-dialog"
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
      a.onTouchTap = (ev) => {
        this.refs.dialog.dismiss();
        if ( this.state.d ) this.state.d.resolve(a.id);
        this.setState({d:null})
      }
      return a;
    })
  }

  confilm() {
    const d = new Deferred();
    this.refs.dialog.show();
    this.setState({d:d})
    return d;
  }
}
ConfirmDialog.propTypes = {
  text:    React.PropTypes.string.isRequired,
  actions: React.PropTypes.array
};
ConfirmDialog.defaultProps = {
  actions: [
    { text: "いいえ", id:"no"  },
    { text: "はい",   id:"yes" }
  ]
};
