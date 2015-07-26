import React                  from "react"
import MUI                    from "material-ui"
import AbstractPage           from "./abstract-page"
import SecuritiesSettingView  from "../settings/securities-setting-view"
import MailAddressSettingView from "../settings/mail-address-setting-view"
import PasswordSettingView    from "../settings/password-setting-view"
import SMTPServerSettingView  from "../settings/smtp-server-setting-view"

export default class SettingsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.model().initialize();
  }

  render() {
    return (
      <div>
        <MailAddressSettingView model={this.model().mailAddressSetting} />
        <PasswordSettingView model={this.model().passwordSetting} />
        <SecuritiesSettingView model={this.model().securitiesSetting} />
        <SMTPServerSettingView model={this.model().smtpServerSetting} />
      </div>
    );
  }

  model() {
    return this.context.application.settingsPageModel;
  }
}

SettingsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
