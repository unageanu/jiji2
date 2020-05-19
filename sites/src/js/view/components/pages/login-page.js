import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

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

export class LoginPage extends AbstractPage {

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
            : this.createPasswordResetterPanel()
        }
      </Card>
    </div>;
  }

  createLoginPanel() {
    const { formatMessage } = this.props.intl;
    return <div className="login-panel">
      <h3><FormattedMessage id='pages.LoginPage.title' /></h3>
      <div className="inputs">
        <TextField
           ref="password"
           floatingLabelText={formatMessage({ id: 'pages.LoginPage.password' })}
           onChange={(ev) => this.setState({password: ev.target.value}) }
           value={this.state.password}
           errorText={this.state.error}
           style={{ width: "100%" }}>
           <input type="password" />
        </TextField>
      </div>
      <div className="buttons">
        <RaisedButton
          label={formatMessage({ id: 'pages.LoginPage.button' })}
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
          <FormattedMessage id='pages.LoginPage.resetPassword' />
        </a>
      </div>
    </div>;
  }

  createPasswordResetterPanel() {
    const { formatMessage } = this.props.intl;
    return <div className="password-resetter">
      <div className="login-link">
        <a onClick={() => this.setState({showPasswordResetter:false})}>
          ← <FormattedMessage id='pages.LoginPage.backToLogin' />
        </a>
      </div>
      <div className="description">
        <FormattedMessage id='pages.LoginPage.resetPasswordFlow.part1' />
      </div>
      <div className="section">
        <div className="info">
          <span className="number">1.</span> <FormattedMessage id='pages.LoginPage.resetPasswordFlow.part2' />
        </div>
        <div className="input">
          <TextField
             floatingLabelText={formatMessage({ id: 'pages.LoginPage.registeredEmail' })}
             onChange={(ev) => this.setState({mailAddress: ev.target.value}) }
             value={this.state.mailAddress}
             style={{ width: "100%" }}
             errorText={this.state.resettinMailSendingError}>
          </TextField>
        </div>
        <div className="buttons">
          <RaisedButton
            label={formatMessage({ id: 'pages.LoginPage.sendPasswordResetMail' })}
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
         <span className="number">2.</span> <FormattedMessage id='pages.LoginPage.resetPasswordFlow.part3' />
        </div>
        <div className="input">
          <TextField
             floatingLabelText={formatMessage({ id: 'pages.LoginPage.token' })}
             onChange={(ev) => this.setState({token: ev.target.value}) }
             errorText={this.state.tokenError}
             value={this.state.token}
             style={{ width: "100%" }}>
          </TextField>
          <TextField
             floatingLabelText={formatMessage({ id: 'common.newPassword' })}
             onChange={(ev) => this.setState({newPassword1: ev.target.value}) }
             value={this.state.newPassword1}
             errorText={this.state.newPasswordError}
             style={{ width: "100%" }}>
             <input type="password" />
          </TextField><br/>
          <TextField
             floatingLabelText={formatMessage({ id: 'common.newPasswordConfirm' })}
             onChange={(ev) => this.setState({newPassword2: ev.target.value}) }
             value={this.state.newPassword2}
             style={{ width: "100%" }}>
             <input type="password" />
          </TextField>
          <div className="description">
            <FormattedMessage id='common.newPasswordDescription' />
          </div>
        </div>
        {this.createErrorContent(this.state.passwordResettingError)}
        <div className="buttons">
          <RaisedButton
            label={formatMessage({ id: 'pages.LoginPage.setNewPassword' })}
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
          → <FormattedMessage id='pages.LoginPage.backToLogin' />
        </a>
      </div>;
    } else {
      return null;
    }
  }

  login(event) {
    this.model().login(this.state.password, this.props.intl.formatMessage);
  }
  sendPasswordResettingMail() {
    this.model().sendPasswordResettingMail(this.state.mailAddress, this.props.intl.formatMessage);
  }
  resetPassword(){
    this.model().resetPassword(this.state.token,
      this.state.newPassword1, this.state.newPassword2, this.props.intl.formatMessage);
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

export default injectIntl(LoginPage);
