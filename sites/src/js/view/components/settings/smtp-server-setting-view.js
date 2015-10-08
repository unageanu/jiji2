import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

const defaultPort = 587;

const keys = new Set([
  "host", "error", "message", "isSaving", "enablePostmark",
  "hostError", "portError", "userNameError", "passwordError"
]);

export default class SMTPServerSettingView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      host:           null,
      port:           defaultPort,
      userName:       null,
      password:       null,
      error:          null,
      hostError:      null,
      portError:      null,
      userNameError:  null,
      passwordError:  null,
      message:        null,
      enablePostmark: true
    };
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model, keys);
    let state = Object.assign({
      host:           model.setting.smtpHost,
      port:           model.setting.smtpPort || defaultPort,
      userName:       model.setting.userName,
      password:       model.setting.password
    }, this.collectInitialState(model, keys));
    this.setState(state);
  }

  render() {
    if (this.state.enablePostmark !== false) return null;
    return (
      <div className="smtp-server-setting">
        <h3>SMTPサーバーの設定</h3>
        {this.createInputFields()}
        <div>
          <RaisedButton
            label="テストメール送信"
            disabled={this.state.isSaving}
            onClick={this.composeTestMail.bind(this)}
          />
          <RaisedButton
            label="設定"
            disabled={this.state.isSaving}
            onClick={this.save.bind(this)}
          />
          <span className="loading">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
        <div className="message">{this.state.message}</div>
        <div className="error">{this.state.error}</div>
      </div>
    );
  }

  createInputFields() {
    return <div>
      <TextField
         floatingLabelText="SMTPサーバー"
         errorText={this.state.hostError}
         onChange={(e) => this.setState({host: e.target.value}) }
         value={this.state.host} />
      <br/>
      <TextField
         floatingLabelText="SMTPサーバーポート"
         errorText={this.state.portError}
         onChange={(e) => this.setState({port: e.target.value}) }
         value={this.state.port} />
      <br/>
      <TextField
         floatingLabelText="ユーザー名"
         errorText={this.state.userNameError}
         onChange={(e) => this.setState({userName: e.target.value}) }
         value={this.state.userName} />
      <br/>
      <TextField
        floatingLabelText="パスワード"
        errorText={this.state.passwordError}
        onChange={(e) => this.setState({password: e.target.value}) }
        value={this.state.password}>
         <input type="password" value={this.state.password} />
      </TextField>
    </div>;
  }

  save() {
    this.model().save(this.collectSetting());
  }
  composeTestMail() {
    this.model().composeTestMail(this.collectSetting());
  }

  onPropertyChanged(k, ev) {
    if (ev.key === "setting") {
      this.setState({
        host:     ev.newValue.smtpHost,
        port:     ev.newValue.smtpPort,
        userName: ev.newValue.userName,
        password: ev.newValue.password
      });
    } else {
      super.onPropertyChanged(k, ev);
    }
  }

  collectSetting() {
    return {
      smtpHost: this.state.host,
      smtpPort: this.state.port,
      userName: this.state.userName,
      password: this.state.password
    };
  }
  model() {
    return this.props.model;
  }
}
SMTPServerSettingView.propTypes = {
  model: React.PropTypes.object
};
SMTPServerSettingView.defaultProps = {
  model: null
};
