import React                  from "react"

import AbstractPage           from "./abstract-page"
import WelcomeView            from "../initial-settings/welcome-view"
import MailaddressSettingView from "../initial-settings/mailaddress-and-password-setting-view"
import SecuritiesSettingView  from "../initial-settings/securities-setting-view"
import SMTPServerSettingView  from "../initial-settings/smtp-server-setting-view"
import SettingFinishedView    from "../initial-settings/setting-finished-view"

import Card from "material-ui/Card"

export default class InitialSettingsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      phase: "none",
      error: ""
    };
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model);
    this.setState({
      phase: model.phase,
      error: model.error
    });
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  render() {
    return (
      <div className="initial-settings-page page">
        <Card className="main-card">
          {this.createBody()}
        </Card>
      </div>
    );
  }

  createBody() {
    const model = this.model();
    switch (this.state.phase) {
      case "welcome":
        return <WelcomeView model={model} />;
      case "mailAddressAndPassword":
        return <MailaddressSettingView model={model} />;
      case "securities":
        return <SecuritiesSettingView model={model} />;
      case "smtpServer":
        return <SMTPServerSettingView model={model} />;
      case "finished":
        return <SettingFinishedView model={model} />;
      default: return null;
    }
  }

  model() {
    return this.context.application.initialSettingsPageModel;
  }
}

InitialSettingsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
