import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

const defaultPort = 587;

const keys = new Set([
  "setting", "error", "message", "isSaving", "enablePostmark",
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
      <div className="smtp-server-setting setting">
        <h3>SMTPサーバーの設定</h3>
        <ul className="description">
          <li>エージェントからのメール送信時に使用するSMTPサーバーを設定します。</li>
        </ul>
        <div className="setting-body">
          {this.createInputFields()}
          <div className="buttons">
            {
              this.state.error ? <div className="error">{this.state.error}</div> : null
            }
            <RaisedButton
              label="テストメール送信"
              disabled={this.state.isSaving}
              onClick={this.composeTestMail.bind(this)}
            />
            <span className="setting-button">
              <RaisedButton
                label="設定"
                primary={true}
                disabled={this.state.isSaving}
                onClick={this.save.bind(this)}
              />
            </span>
            <span className="loading">
              {this.state.isSaving ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.message}</div>
        </div>
      </div>
    );
  }

  createInputFields() {
    return <div className="inputs">
      <div className="host-and-port">
        <div className="host">
          <TextField
             floatingLabelText="SMTPサーバー"
             errorText={this.state.hostError}
             onChange={(e) => this.setState({host: e.target.value}) }
             value={this.state.host}
             style={{ width: "100%" }} />
        </div>
        <div className="port">
          <TextField
             floatingLabelText="SMTPサーバーポート"
             errorText={this.state.portError}
             onChange={(e) => this.setState({port: e.target.value}) }
             value={this.state.port}
             style={{ width: "100%" }} />
        </div>
      </div>
      <div className="username-and-password">
        <div className="username">
          <TextField
             floatingLabelText="ユーザー名"
             errorText={this.state.userNameError}
             onChange={(e) => this.setState({userName: e.target.value}) }
             value={this.state.userName}
             style={{ width: "100%" }} />
        </div>
        <div className="password">
          <TextField
            floatingLabelText="パスワード"
            errorText={this.state.passwordError}
            onChange={(e) => this.setState({password: e.target.value}) }
            value={this.state.password}
            style={{ width: "100%" }}>
             <input type="password" value={this.state.password} />
          </TextField>
        </div>
      </div>
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
