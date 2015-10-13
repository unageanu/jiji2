import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import LoadingImage from "../widgets/loading-image"

const TextField    = MUI.TextField;
const Card         = MUI.Card;
const RaisedButton = MUI.RaisedButton;

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
      this.registerPropertyChangeListener(this.model(), keys);
      const state = this.collectInitialState(this.model(), keys);
      state.showPasswordResetter = false;
      this.setState(state);
  }

  render() {
    const error = this.state.error
      ? <div className="error">{this.state.error}</div>
      : null;
    return (
      <div className="login-page">
        <Card className="card">
          <div className="inputs">
            <TextField
               ref="password"
               floatingLabelText="パスワード"
               onChange={(ev) => this.setState({password: ev.target.value}) }
               value={this.state.password}
               style={{ width: "100%" }}>
               <input type="password" />
            </TextField>
          </div>
          {error}
          <div className="buttons">
            <RaisedButton
              label="ログイン"
              primary={true}
              disabled={this.state.isAuthenticating}
              onClick={this.login.bind(this)}
              style={{ width: "100%" }}
            />
            <span className="loading">
              {this.state.isAuthenticating ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div>
            {this.createPasswordResetter()}
          </div>
        </Card>
      </div>
    );
  }

  createPasswordResetter() {
    if ( !this.state.showPasswordResetter ) {
      return <a onClick={() => this.setState({showPasswordResetter:true})}>
        パスワードを忘れた場合...
      </a>;
    } else {
      return <div>
        <div className="description">
          以下の手順に従って、パスワードを再設定してください。
        </div>
        <div className="section">
          <div className="info">
            ① システムに登録しているメールアドレスを入力して、[パスワード再設定メールを送る]ボタンを押してください。
          </div>
          <div className="input">
            <TextField
               floatingLabelText="登録済みメールアドレス"
               onChange={(ev) => this.setState({mailAddress: ev.target.value}) }
               value={this.state.mailAddress}
               style={{ width: "100%" }}>
            </TextField>
          </div>
          {this.createError(this.state.resettinMailSendingError)}
          <div className="buttons">
            <RaisedButton
              label="パスワード再設定メールを送る"
              primary={true}
              disabled={this.state.isSendingMail}
              onClick={this.sendPasswordResettingMail.bind(this)}
              style={{ width: "100%" }}
            />
            <span className="loading">
              {this.state.isSendingMail ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.resettinMailSentMessage}</div>
        </div>
        <div className="section">
          ② 登録しているメールアドレスに[パスワード再設定メール]が送信されます。<br/>
          　メールに記載されている[トークン]と新しいパスワードを入力して、パスワードを再設定してください。
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
          {this.createError(this.state.passwordResettingError)}
          <div className="buttons">
            <RaisedButton
              label="パスワードを再設定する"
              primary={true}
              disabled={this.state.isResettingPassword}
              onClick={this.resetPassword.bind(this)}
              style={{ width: "100%" }}
            />
            <span className="loading">
              {this.state.isResettingPassword ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.passwordResettingMessage}</div>
        </div>
      </div>;
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

  createError(error) {
    return error ? <div className="error">{error}</div> : null;
  }

  model() {
    return this.context.application.loginPageModel;
  }
}

LoginPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
