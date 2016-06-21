import React                  from "react"

import AbstractPage           from "./abstract-page"
import SecuritiesSettingView  from "../settings/securities-setting-view"
import MailAddressSettingView from "../settings/mail-address-setting-view"
import PasswordSettingView    from "../settings/password-setting-view"
import PairSettingView        from "../settings/pair-setting-view"
import SMTPServerSettingView  from "../settings/smtp-server-setting-view"

import Card from "material-ui/Card"

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
      <div className="settings-page page">
        <Card className="main-card">
          <div className="item">
            <MailAddressSettingView model={this.model().mailAddressSetting} />
          </div>
          <div className="item">
            <PasswordSettingView model={this.model().passwordSetting} />
          </div>
          <div className="item">
            <SecuritiesSettingView model={this.model().securitiesSetting} />
          </div>
          <div className="item">
            <PairSettingView model={this.model().pairSetting} />
          </div>
          <div className="item">
            <SMTPServerSettingView model={this.model().smtpServerSetting} />
          </div>
        </Card>
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
