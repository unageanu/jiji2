import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

const defaultPort = 587;

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
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      host:           this.props.model.setting.smtpHost,
      port:           this.props.model.setting.smtpPort || defaultPort,
      userName:       this.props.model.setting.userName,
      password:       this.props.model.setting.password,
      error:          this.props.model.error,
      hostError:      this.props.model.hostError,
      portError:      this.props.model.portError,
      userNameError:  this.props.model.userNameError,
      passwordError:  this.props.model.passwordError,
      message:        this.props.model.message,
      enablePostmark: this.props.model.enablePostmark
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    if (this.state.enablePostmark !== false) return null;
    return (
      <div className="smtp-server-setting">
        <h3>SMTPサーバーの設定</h3>
        <div>
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
        </div>
        <br/>
        <RaisedButton
          label="テストメール送信"
          onClick={this.composeTestMail.bind(this)}
        />
        <RaisedButton
          label="設定"
          onClick={this.save.bind(this)}
        />
        <div className="message">{this.state.message}</div>
        <div className="error">{this.state.error}</div>
      </div>
    );
  }
  save() {
    this.props.model.save(this.collectSetting());
  }
  composeTestMail() {
    this.props.model.composeTestMail(this.collectSetting());
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
}
SMTPServerSettingView.propTypes = {
  model: React.PropTypes.object
};
SMTPServerSettingView.defaultProp = {
  model: null
};
