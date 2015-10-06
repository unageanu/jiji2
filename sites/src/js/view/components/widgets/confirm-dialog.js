import React        from "react"
import MUI          from "material-ui"
import Deferred     from "../../../utils/deferred"

const Dialog       = MUI.Dialog;

export default class ConfirmDialog extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Dialog
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
        this.d.resolve(a.id);
        this.d = null;
      }
      return a;
    })
  }

  confilm() {
    this.d = new Deferred();
    this.refs.dialog.show();
    return this.d;
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
