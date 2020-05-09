import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "error", "message", "isSaving"
]);

class PasswordSettingView extends AbstractComponent {

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
      <div className="securities-setting setting">
        <h3><FormattedMessage id='settings.PasswordSettingView.title'/></h3>
        <ul className="description">
          <li><FormattedMessage id='settings.PasswordSettingView.description'/></li>
        </ul>
        <div className="setting-body">
          {body}
        </div>
      </div>
    );
  }

  createEditPasswordButton() {
    const { formatMessage } = this.props.intl;
    return <div className="buttons">
      <RaisedButton
        label={formatMessage({ id: 'settings.PasswordSettingView.changePassword' })}
        onClick={this.startToEditPassword.bind(this)}
      />
    </div>;
  }
  createPasswordChanger() {
    const { formatMessage } = this.props.intl;
    return <div>
      <div className="passwords">
        <TextField
           ref="newPassword1"
           floatingLabelText={formatMessage({ id: 'common.newPassword' })}
           onChange={this.onNewPassword1Changed.bind(this)}
           value={this.state.newPassword1}
           style={{ width: "100%" }}>
           <input type="password" />
        </TextField><br/>
        <TextField
           ref="newPassword2"
           floatingLabelText={formatMessage({ id: 'common.newPasswordConfirm' })}
           onChange={this.onNewPassword2Changed.bind(this)}
           value={this.state.newPassword2}
           style={{ width: "100%" }}>
           <input type="password" />
        </TextField>
        <div className="description">
          <FormattedMessage id='common.newPasswordDescription'/>
        </div>
        <TextField
           ref="oldPassword"
           floatingLabelText={formatMessage({ id: 'settings.PasswordSettingView.oldPassword' })}
           onChange={this.onOldPasswordChanged.bind(this)}
           value={this.state.oldPassword}
           style={{ width: "100%" }}>
           <input type="password" />
        </TextField>
      </div>
      <div className="buttons">
        {this.createErrorContent(this.state.error)}
        <RaisedButton
          label={formatMessage({ id: 'settings.PasswordSettingView.change' })}
          primary={true}
          disabled={this.state.isSaving}
          onClick={this.save.bind(this)}
        />
        <span className="loading-for-button-action">
          {this.state.isSaving ? <LoadingImage size={20} /> : null}
        </span>
      </div>
      <div className="message">{this.state.message}</div>
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
    this.props.model.save(newPassword1, newPassword2, oldPassword, this.props.intl.formatMessage);
  }
}
PasswordSettingView.propTypes = {
  model: React.PropTypes.object
};
PasswordSettingView.defaultProps = {
  model: null
};
export default injectIntl(PasswordSettingView);
