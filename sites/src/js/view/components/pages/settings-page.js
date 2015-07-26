import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import SecuritiesSettingView from "../settings/securities-setting-view"

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
        <SecuritiesSettingView model={this.model().securitiesSetting} />
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
