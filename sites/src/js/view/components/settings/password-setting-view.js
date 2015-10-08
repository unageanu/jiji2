import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

const keys = new Set([
  "error", "message", "isSaving"
]);

export default class PasswordSettingView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      newPassword1:  null,
      newPassword2:  null,
      oldPassword:   null,
      editPassword:  false
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    const body = this.state.editPassword
      ? this.createPasswordChanger()
      : this.createEditPasswordButton();
    return (
      <div className="securities-setting">
        <h3>パスワードの変更</h3>
        <div>
        {body}
        </div>
      </div>
    );
  }

  createEditPasswordButton() {
    return <RaisedButton
        label="パスワードを変更する"
        onClick={this.startToEditPassword.bind(this)}
      />;
  }
  createPasswordChanger() {
    return <div>
      <TextField
         ref="newPassword1"
         floatingLabelText="新しいパスワード"
         onChange={this.onNewPassword1Changed.bind(this)}
         value={this.state.newPassword1}>
         <input type="password" />
      </TextField><br/>
      <TextField
         ref="newPassword2"
         floatingLabelText="新しいパスワード(確認のため、もう一度入力してください)"
         onChange={this.onNewPassword2Changed.bind(this)}
         value={this.state.newPassword2}>
         <input type="password" />
      </TextField><br/>
      <TextField
         ref="oldPassword"
         floatingLabelText="現在のパスワード"
         onChange={this.onOldPasswordChanged.bind(this)}
         value={this.state.oldPassword}>
         <input type="password" />
      </TextField>
      <div>
        <RaisedButton
          label="変更"
          disabled={this.state.isSaving}
          onClick={this.save.bind(this)}
        />
        <span className="loading">
          {this.state.isSaving ? <LoadingImage size={20} /> : null}
        </span>
      </div>
      <div className="message">{this.state.message}</div>
      <div className="error">{this.state.error}</div>
    </div>;
  }

  onNewPassword1Changed(event) {
    this.setState({newPassword1: event.target.value});
  }
  onNewPassword2Changed(event) {
    this.setState({newPassword2: event.target.value});
  }
  onOldPasswordChanged(event) {
    this.setState({oldPassword: event.target.value});
  }
  startToEditPassword() {
    this.setState({editPassword: true});
  }
  save() {
    const newPassword1 = this.state.newPassword1;
    const newPassword2 = this.state.newPassword2;
    const oldPassword  = this.state.oldPassword;
    this.props.model.save(newPassword1, newPassword2, oldPassword);
  }
}
PasswordSettingView.propTypes = {
  model: React.PropTypes.object
};
PasswordSettingView.defaultProps = {
  model: null
};
