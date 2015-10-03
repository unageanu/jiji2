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
        title={this.props.text}
        actions={this.createActions()}
        modal={true}
      />
    );
  }

  createActions() {
    return this.props.actions.map((a) => {
      a.onTouchTap = () => {
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
  actions: React.PropTypes.string
};
ConfirmDialog.defaultProps = {
  actions: [
    { text: "いいえ", id:"no"  },
    { text: "はい",   id:"yes" }
  ]
};
