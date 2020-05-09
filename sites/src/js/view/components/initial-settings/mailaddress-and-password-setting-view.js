import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent      from "../widgets/abstract-component"
import LoadingImage           from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "error", "isSaving"
]);

class MailaddressAndPasswordSettingView
extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      mailError:     null,
      mailAddress:   null,
      password1:     null,
      password2:     null,
      passwordError: null,
      error:         null,
      isSaving:      false
    };
  }

  componentWillMount() {
    const mailSetting = this.props.model.mailAddressSetting;
    mailSetting.addObserver("propertyChanged", (k, ev) => {
      if (ev.key === "error") this.setState({mailError:ev.newValue});
    }, this);
    const passwordSetting = this.props.model.passwordSetting;
    passwordSetting.addObserver("propertyChanged", (k, ev) => {
      if (ev.key === "error") this.setState({passwordError:ev.newValue});
    }, this);
    this.registerPropertyChangeListener(this.props.model, keys);

    this.setState(Object.assign({
      mailError:     mailSetting.error,
      passwordError: passwordSetting.error
    }, this.collectInitialState(this.props.model, keys)));
  }

  componentWillUnmount() {
    this.props.model.mailAddressSetting.removeAllObservers(this);
    this.props.model.passwordSetting.removeAllObservers(this);
    this.props.model.removeAllObservers(this);
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="mailaddress-and-password-setting-view">
        <h3><FormattedMessage id='initialSettings.MailaddressAndPasswordSettingView.title'/></h3>
        <div className="description">
          <FormattedMessage id='initialSettings.MailaddressAndPasswordSettingView.description.part1'/>
        </div>
        <ul className="description">
          <li><FormattedMessage id='initialSettings.MailaddressAndPasswordSettingView.description.part2'/></li>
          <li>
            <FormattedMessage id='initialSettings.MailaddressAndPasswordSettingView.description.part3'/>
          </li>
        </ul>
        <div className="inputs">
          <div className="mail-address">
            <TextField
               ref="mailAddress"
               floatingLabelText={formatMessage({ id: 'initialSettings.MailaddressAndPasswordSettingView.mailAddress' })}
               errorText={this.state.mailError}
               onChange={(e) => this.setState({mailAddress: e.target.value}) }
               value={this.state.mailAddress}
               style={{ width: "100%" }}
                />
          </div>
          <div className="password">
            <TextField
                ref="newPassword1"
                floatingLabelText={formatMessage({ id: 'initialSettings.MailaddressAndPasswordSettingView.password' })}
                onChange={(e) => this.setState({password1: e.target.value}) }
                errorText={this.state.passwordError}
                value={this.state.password1}
                style={{ width: "100%" }}>
                <input type="password" />
            </TextField>
          </div>
          <div className="password">
            <TextField
                ref="newPassword2"
                floatingLabelText={formatMessage({ id: 'initialSettings.MailaddressAndPasswordSettingView.passwordConfirm' })}
                onChange={(e) => this.setState({password2: e.target.value}) }
                errorText={this.state.passwordError}
                value={this.state.password2}
                style={{ width: "100%" }}>
                <input type="password" />
            </TextField>
            <div className="description">
              <FormattedMessage id='initialSettings.MailaddressAndPasswordSettingView.passwordConfirmDescription'/>
            </div>
          </div>
        </div>
        {this.createErrorContent(this.state.error)}
        <div className="buttons">
          <span className="button">
            <RaisedButton
              label={formatMessage({ id: 'common.button.next' })}
              onClick={this.next.bind(this)}
              disabled={this.state.isSaving}
              primary={true}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="loading-for-button-action">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
      </div>
    );
  }

  next() {
    this.props.model.setMailAddressAndPassword(
      this.state.mailAddress, this.state.password1,
      this.state.password2, this.props.intl.formatMessage);
  }
}
MailaddressAndPasswordSettingView.propTypes = {
  model: React.PropTypes.object
};
MailaddressAndPasswordSettingView.defaultProps = {
  model: null
};
export default injectIntl(MailaddressAndPasswordSettingView);
