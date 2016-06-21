import React        from "react"

import AbstractPage from "./abstract-page"
import LoadingImage from "../widgets/loading-image"

import TextField from "material-ui/TextField"
import Card from "material-ui/Card"
import RaisedButton from "material-ui/RaisedButton"

const keys = new Set([
  "error", "isAuthenticating",
  "resettinMailSendingError",
  "resettinMailSentMessage",
  "isSendingMail",
  "tokenError",
  "newPasswordError",
  "passwordResettingError",
  "passwordResettingMessage",
  "isResettingPassword"
]);

export default class LoginPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      error: ""
    };
  }

  componentWillMount() {
    const keys = this.getKeys();
    this.registerPropertyChangeListener(this.model(), keys);
    const state = this.collectInitialState(this.model(), keys);
    state.showPasswordResetter = false;
    this.setState(state);

    this.model().initialize();
  }

  render() {
    return <div className="login-page page">
      <Card className="main-card">
        {
          !this.state.showPasswordResetter
            ? this.createLoginPanel()
            :  this.createPasswordResetterPanel()
        }
      </Card>
    </div>;
  }

  createLoginPanel() {
    return <div className="login-panel">
      <h3>ログイン</h3>
      <div className="inputs">
        <TextField
           ref="password"
           floatingLabelText="パスワード"
           onChange={(ev) => this.setState({password: ev.target.value}) }
           value={this.state.password}
           errorText={this.state.error}
           style={{ width: "100%" }}>
           <input type="password" />
        </TextField>
      </div>
      <div className="buttons">
        <RaisedButton
          label="ログイン"
          primary={true}
          disabled={this.state.isAuthenticating}
          onClick={this.login.bind(this)}
          style={{
            width: "100%",
            height:"50px"
          }}
          labelStyle={{
            fontSize: "20px",
            lineHeight:"50px"
          }}/>
      </div>
      {this.createLoginPanelBottomContent()}
      <div className="resetter-link">
        <a onClick={() => this.setState({showPasswordResetter:true})}>
          パスワードを忘れた場合...
        </a>
      </div>
    </div>;
  }

  createPasswordResetterPanel() {
    return <div className="password-resetter">
      <div className="login-link">
        <a onClick={() => this.setState({showPasswordResetter:false})}>
          ← ログイン画面に戻る
        </a>
      </div>
      <div className="description">
        パスワードを忘れた方は、以下の手順に従ってパスワードを再設定してください。
      </div>
      <div className="section">
        <div className="info">
          <span className="number">1.</span> システムに登録しているメールアドレスを入力して、 [パスワード再設定メールを送る] ボタンを押してください。
        </div>
        <div className="input">
          <TextField
             floatingLabelText="登録済みメールアドレス"
             onChange={(ev) => this.setState({mailAddress: ev.target.value}) }
             value={this.state.mailAddress}
             style={{ width: "100%" }}
             errorText={this.state.resettinMailSendingError}>
          </TextField>
        </div>
        <div className="buttons">
          <RaisedButton
            label="パスワード再設定メールを送る"
            primary={true}
            disabled={this.state.isSendingMail}
            onClick={this.sendPasswordResettingMail.bind(this)}
          />
          <span className="loading-for-button-action">
            {this.state.isSendingMail ? <LoadingImage size={20} /> : null}
          </span>
        </div>
        <div className="message">{this.state.resettinMailSentMessage}</div>
      </div>
      <div className="section">
        <div className="info">
         <span className="number">2.</span> 登録されているメールアドレスに [パスワード再設定メール] が送信されます。メールを開封し、記載されている [トークン] と新しいパスワードを入力して、パスワードを再設定してください。
        </div>
        <div className="input">
          <TextField
             floatingLabelText="トークン"
             onChange={(ev) => this.setState({token: ev.target.value}) }
             errorText={this.state.tokenError}
             value={this.state.token}
             style={{ width: "100%" }}>
          </TextField>
          <TextField
             floatingLabelText="新しいパスワード"
             onChange={(ev) => this.setState({newPassword1: ev.target.value}) }
             value={this.state.newPassword1}
             errorText={this.state.newPasswordError}
             style={{ width: "100%" }}>
             <input type="password" />
          </TextField><br/>
          <TextField
             floatingLabelText="新しいパスワード (確認用)"
             onChange={(ev) => this.setState({newPassword2: ev.target.value}) }
             value={this.state.newPassword2}
             style={{ width: "100%" }}>
             <input type="password" />
          </TextField>
          <div className="description">
            ※確認のため、新しいパスワードを再入力してください。
          </div>
        </div>
        {this.createErrorContent(this.state.passwordResettingError)}
        <div className="buttons">
          <RaisedButton
            label="パスワードを再設定する"
            primary={true}
            disabled={this.state.isResettingPassword}
            onClick={this.resetPassword.bind(this)}
          />
          <span className="loading-for-button-action">
            {this.state.isResettingPassword ? <LoadingImage size={20} /> : null}
          </span>
        </div>
        {this.createResettingMessage()}
      </div>
    </div>;
  }

  createResettingMessage() {
    if (this.state.passwordResettingMessage) {
      return <div className="message">
        {this.state.passwordResettingMessage}
        <a onClick={() => this.setState({showPasswordResetter:false})}>
          → ログイン画面に戻る
        </a>
      </div>;
    } else {
      return null;
    }
  }

  login(event) {
    this.model().login(this.state.password);
  }
  sendPasswordResettingMail() {
    this.model().sendPasswordResettingMail(this.state.mailAddress);
  }
  resetPassword(){
    this.model().resetPassword(this.state.token,
      this.state.newPassword1, this.state.newPassword2);
  }

  createLoginPanelBottomContent() {
    return null;
  }

  getKeys() {
    return keys;
  }

  model() {
    return this.context.application.loginPageModel;
  }
}

LoginPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
